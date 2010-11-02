# Displays basic static company pages.
class PagesController < ApplicationController
  
  # Search page.
  def search      
    # If no URL has been set, grab the whole request URI, remove 
    # the leading forward-slash, and treat it as the URL.    
    unless params[:url]
      url = request.fullpath.sub(/^\//, '')
      if url != ''
        params[:url] = url
      end
    end
    
    if params[:url]
      search     = Search.new
      search.url = params[:url]
    
      # Redirect minus-the-http if present
      if search.url =~ /^http:\/\//
        url = search.url.sub /^http:\/\//, ''
        redirect_to "http://#{get_domain}/#{url}"
        return
      end    
    
      unless search.valid?
        flash[:alert] = t 'pages.search.invalid_url_warning'
        return
      end
      
      result = search.result
      
      unless result
        render_404 and return
      end
      
      render :text => result
    end   
  end
  
  # About-this-site page.
  def about
    render :layout => 'page'
  end
  
  # Renders the 404 page.
  def render_404
    @title = "#{controller_name}.error.title"
    render :template => "/pages/error.html.haml", 
           :layout   => 'page', 
           :status   => 404, 
           :locals   => {:url => params[:url]}
  end

end
