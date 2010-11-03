# Models a search for a particular URL.

require 'hpricot'
require 'open-uri'
require 'timeout'
    
class Search
  
  include ActiveModel::Validations
  
  validates_presence_of :url
  validates_format_of   :url, :with => /(^$)|(^((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?[\/\?\#].*)?$)/ix
  
  # To deal with the form, you must have an id attribute.
  attr_accessor :id, :url
  
  
  # Over-ride the URL setter - rails seems to convert double-forward-slashes to single
  # when we send the URL without the '?url=' prefix.
  def url=(_url)
    @url = _url.sub(/(^https?:\/)([^\/])/, '\1/\2')
  end
  
  
  # Process the URL, and try to get the result from the cache.
  def result
    url = @url
    
    # Prepend HTTP if it's not there already.
    unless url =~ /^http:\/\//
      url = 'http://' + url
    end
    
    # Check the cache for this URL.
    cached_version = read_cache(url)
    return cached_version if cached_version != false
    
    result = fetch_from_google_cache(url)
    result = fetch_from_original(url) unless result
        
    add_javascript(result[:content]) if result
    
    # Store this in the cache for subsequent requests.
    return write_cache(result, url)
  end
  
  
  private
  
  
  # Write this result to the cache.
  def write_cache(result, url)
    if result
      result[:content] = result[:content].inner_html
      Rails.cache.write(url, result, :expires_in => 30.minutes)
      return result
    else
      # Return nil if we couldn't retrieve anything.
      Rails.cache.write(url, '__nil__', :expires_in => 30.minutes)
      return nil
    end
  end
  
  
  # Attempt to read this result form the cache.
  def read_cache(url)
    cached_version = Rails.cache.read(url)
    if cached_version
      Rails.logger.debug "Retrieved from cache : #{url}"
      if cached_version == '__nil__'
        return nil
      else
        return cached_version
      end
    end
    
    return false
  end
  
  
  # Attempt to fetch this page from the google cache.
  def fetch_from_google_cache(url)
    cache_url = "http://webcache.googleusercontent.com/search?q=cache:#{CGI::escape(url)}"
    result    = scrape_url(cache_url)
    
    # If success, remove the google cache header.
    if result
      result[:content] = result[:content]/"html"
      add_source(result[:content], cache_url)
      source  = CGI::escape(cache_url)
      add_base_href(result[:content], url)
    end
    
    result
  end
  
  
  # Attempt to fetch from the original URL.
  def fetch_from_original(url)
    result = scrape_url(url)
    if result
      add_source(result[:content], url)
      add_base_href(result[:content]/"html", url)
    end
    
    result
  end
  
  
  # Add custom javascript to display source badge.
  def add_javascript(content)
    if Rails.env.development?
      script_tag  = '<script src="http://localhost:3000/javascripts/jquery.js"></script>'
      script_tag += '<script src="http://localhost:3000/javascripts/jquery.placeholder.js"></script>'
      script_tag += '<script src="http://localhost:3000/javascripts/application.js"></script>'
    else
      script_tag = '<script src="http://fromthecache.com/assets/common.js"></script>'
    end
    (content/"body").append(script_tag)
  end
  
  
  # Add a hidden 'source' field to the page.
  def add_source(content, url)
    url        = CGI::escape(url)
    hidden_tag = "<input type='hidden' id='scrape_source' value='#{url}'>"
    (content/"body").append(hidden_tag)
  end
  
  
  # Add a <base> tag to make links work correctly.
  def add_base_href(content, url)
    content.prepend("<base href='#{url}'>")
  end
  
  
  # Returns a hash of params identifying our scraper.
  def scraper_params
    {"User-Agent" => "fromthecache.com scraper", "From" => "mail@fromthecache.com"}
  end
  
  
  # Scrape the given URL and return the content.
  def scrape_url(url)
    content      = nil
    content_type = 'text/html'
    
    # Set up a timeout for the scrape request.
    Timeout::timeout(APP_CONFIG['scrape_timeout']) {
      conn         = open(url, scraper_params)
      content_type = conn.content_type
      content      = Hpricot(conn)
    }
    
    return nil if is_invalid_page(content)
    
    {:content => content, :content_type => content_type}
  rescue Timeout::Error
    Rails.logger.debug "Request timed out retrieving #{url}."
    nil
  rescue
    Rails.logger.info "Couldn't load URL #{url}"
    nil
  end
  
  
  # Return true if this looks like an invalid/error page, false otherwise.
  def is_invalid_page(content)
    # Return true if content is false
    return true unless content 
    
    # Check if we've hit the google cache 404 or search pages.
    if content.inner_text =~ / - did not match any documents\./
      #This happens if the page is not in the cache.
      return true
    elsif (content/"title").inner_text =~ /^cache:http.*Google Search$/
      # This happens for searches that aren't a real domain - eg. http://asdf.ert/.
      return true
    elsif content.inner_text =~ /it appears your computer is sending automated requests/
      # This happens if we get blocked by google for looking like a bot.
      return true
    end
    
    return false
  end
  
end


# Monkey-patch OpenURI to allow http->https redirection.
module OpenURI
  def OpenURI.redirectable?(uri1, uri2)
    uri1.scheme.downcase == uri2.scheme.downcase ||
    (/\A(?:https?|ftp)\z/i =~ uri1.scheme && /\A(?:https?|ftp)\z/i =~ uri2.scheme)
  end
end