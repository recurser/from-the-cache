# Displays basic static company pages.
class PagesController < ApplicationController
  
  # Search page.
  def search      
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
  
  # About-this-project page.
  def about
    render :layout => 'page'
  end

end
