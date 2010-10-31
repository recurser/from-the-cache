# Models a search for a particular URL.
class Search
  
  include ActiveModel::Validations
  
  validates_presence_of :url
  validates_format_of   :url, :with => /(^$)|(^((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
  
  # To deal with the form, you must have an id attribute.
  attr_accessor :id, :url
  
  # Process the URL, and try to get the result from the cache.
  def result
    require 'hpricot'
    require 'open-uri'
    
    # Prepend HTTP if it's not there already.
    # TODO
    
    # Extract the method (http/https).
    # TODO
    
    # Extract the domain.
    domain = URI.parse(@url).host
    
    # Get the page from google cache.
    cache_url = "http://webcache.googleusercontent.com/search?q=cache:#{@url}"
    content = Hpricot(open(cache_url,
      "User-Agent" => "fromthecache.com crawler",
      "From"       => "mail@fromthecache.com")
    )
    
    # Check for success.
    # TODO
    success = true
    
    # If success, remove the google cache header.
    if success
      content = content/"body"
    end
    
    # Use <base href="http://recursive-design.com/"> ala google?
    # Add a hidden field at the end of the page containing the original url path.
    # TODO
    
    # Add custom javascript to rewrite relative links, CSS, JScript, images etc.
    # TODO
    
    content
  end
  
end
