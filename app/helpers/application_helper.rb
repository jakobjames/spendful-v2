module ApplicationHelper
  include AuthenticationMethods
  
  def title(page_title)
    content_for(:title) { page_title }
  end

	def users_path(options)
		signup_path(options)
	end

	def page?
		params[:controller] == "pages" ||
		params[:controller] == "sessions" ||
		params[:controller] == "users" && params[:action] == "new" ||
		params[:controller] == "users" && params[:action] == "create" ||
		params[:controller] == "passwords"
	end
	
	def page_classes
		"#{params[:controller]} #{params[:action]} #{@body_class}"
	end

end
