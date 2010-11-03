# Commonly used view functions.
module ApplicationHelper
  
  # Return a title on a per-page basis.
  def title
    base_title = t 'common.title_prefix'
    page_title = t @title
    separator  = t 'common.title_separator'
    "#{base_title}#{separator}#{page_title}"
  end
  
  # Gives each page a unique ID to provide CSS hooks.
  def body_id
    "#{controller_name}_#{action_name}"
  end
  
end
