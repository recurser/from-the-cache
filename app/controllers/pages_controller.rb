# Displays basic static company pages.
class PagesController < ApplicationController
  
  # Search page.
  def search      
    # If no URL has been set, grab the whole request URI, remove 
    # the leading forward-slash, and treat it as the URL.
    unless params[:url]
      url = request.request_uri.sub(/^\//, '')
      if url != ''
        params[:url] = url
      end
    end
    
    if params[:url]
      @search     = Search.new
      @search.url = params[:url]
      unless @search.valid?
        flash[:alert] = t 'pages.search.invalid_url_warning'
        return
      end
      
      render :text => @search.result
    end   
  end
  
  # About-this-site page.
  def about
    render :layout => 'page'
  end

end
