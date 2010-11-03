# Base controller for the application.
class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  before_filter :set_title
  
  # Set the title of the current page based on the controller and action name.
  def set_title
     @title = "#{controller_name}.#{action_name}.title"
  end
  
end
