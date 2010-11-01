# Base controller for the application.
class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  before_filter :set_title
  
  # Redirect un-authorized accesses to the home page, and display a message.
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end
  
  # Get roles accessible by the current user
  def accessible_roles
    # Don't display user role - it gets added automatically and should be 
    # transparent to the system.
    @accessible_roles = Role.accessible_by(current_ability, :read) - [Role.by_name(:user)]
  end
 
  # Make the current user object available to views
  def get_user
    @current_user = current_user
  end
  
  # Set the title of the current page based on the controller and action name.
  def set_title
     @title = "#{controller_name}.#{action_name}.title"
  end
  
  # Returns the current domain (and port if present).
  def get_domain
    result = request.host
    port   = request.port
    
    if port != 80
      result = result + ':' + port.to_s
    end
    
    result
  end
  
end
