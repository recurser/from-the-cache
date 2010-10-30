# Displays basic static company pages.
class PagesController < ApplicationController
  
  # Site top-page.
  def home
   
  end
  
  # About-this-project page.
  def about
    render :layout => 'page'
  end

end
