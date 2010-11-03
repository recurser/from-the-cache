# Displays basic static company pages.
class PagesController < ApplicationController
  
  # Search page.
  def search  
    process_params
    
    if params[:url]
      @search     = Search.new
      @search.url = params[:url]
      
      return if redirect_http_search
    
      return unless is_valid_search
      
      result = @search.result
      
      render_404 and return unless result
      
      render :text => result[:content], :content_type => result[:content_type]
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
  
  private
  
  # If no URL has been set, grab the whole request URI, remove 
  # the leading forward-slash, and treat it as the URL.    
  def process_params
    unless params[:url]
      url = request.fullpath.sub(/^\//, '')
      if url != ''
        params[:url] = url
      end
    end
  end
  
  # Redirect minus-the-http if present.
  def redirect_http_search
    if @search.url =~ /^http:\/\//
      url = @search.url.sub /^http:\/\//, ''
      redirect_to "/#{url}" and return true
    end    
    
    return false
  end
  
  # Display a flash message if the search is invalid.
  def is_valid_search
    unless @search.valid?
      flash[:alert] = t 'pages.search.invalid_url_warning'
      return false
    end
    
    return true
  end

end
