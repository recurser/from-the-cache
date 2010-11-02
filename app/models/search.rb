# Models a search for a particular URL.
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
    require 'hpricot'
    require 'open-uri'
    
    processed_url = @url
    
    # Prepend HTTP if it's not there already.
    unless processed_url =~ /^http:\/\//
      processed_url = 'http://' + processed_url
    end
    
    # Check the cache for this URL.
    cached = Rails.cache.read(processed_url)
    if cached
      Rails.logger.debug "Retrieved from cache : #{processed_url}"
      if cached == '__nil__'
        return nil
      else
        return cached
      end
    end
    
    # URL-encode the url
    escaped_url = CGI::escape(processed_url)
    
    # Use <base href="http://recursive-design.com/"> ala google
    base_href = "<base href='#{processed_url}'>"
    
    # Get the page from google cache.
    cache_url = "http://webcache.googleusercontent.com/search?q=cache:#{escaped_url}"
    content = scrape_url(cache_url)
    
    # If success, remove the google cache header.
    if content
      content = content/"html"
      source  = CGI::escape(cache_url)
      (content).prepend(base_href)
    end
    
    # If the google cache call failed, try to get the original URL.
    unless content
      content = scrape_url(processed_url)
      source  = escaped_url
      if content
        (content/"html").prepend(base_href)
      end
    end
    
    # Return false if we still couldn't retrieve anything.
    unless content
      Rails.cache.write(processed_url, '__nil__', :expires_in => 30.minutes)
      return false
    end
    
    # Add custom javascript to rewrite relative links, CSS, JScript, images etc.
    if Rails.env.development?
      script_tag  = '<script src="http://localhost:3000/javascripts/jquery.js"></script>'
      script_tag += '<script src="http://localhost:3000/javascripts/application.js"></script>'
    else
      script_tag = '<script src="http://fromthecache.com/assets/common.js"></script>'
    end
    (content/"body").append(script_tag)
    
    # Add a hidden field so we know the source of the page.
    hidden_tag = "<input type='hidden' id='scrape_source' value='#{source}'>"
    (content/"body").append(hidden_tag)
    
    # Store this in the cache for subsequent requests.
    result = content.inner_html
    Rails.cache.write(processed_url, result, :expires_in => 30.minutes)
    result
  end
  
  private
  
  # Scrape the given URL and return the content.
  def scrape_url(url)
    Rails.logger.debug "Fetching #{url}"
    
    # Set up a timeout for the scrape request.
    require 'timeout'
    content = nil
    begin
      Timeout::timeout(APP_CONFIG['scrape_timeout']) {
        content = Hpricot(open(url,
          "User-Agent" => "fromthecache.com scraper",
          "From"       => "mail@fromthecache.com")
        )
      }
    rescue Timeout::Error
      Rails.logger.debug "Request timed out."
      return nil
    end
    
    # Check if we've hit the google cache 404 or search pages.
    if content 
      if content.inner_text =~ / - did not match any documents\./
        # This happens if the page is not in the cache.
        return nil
      elsif (content/"title").inner_text =~ /^cache:http.*Google Search$/
        # This happens for searches that aren't a real domain - eg. http://asdf.ert/.
        return nil
      end
    end
    
    content
  #rescue
  #  Rails.logger.info "Couldn't load URL #{url}"
  #  nil
  end
  
end

