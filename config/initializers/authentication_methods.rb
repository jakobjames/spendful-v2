module AuthenticationMethods
  def current_user
    uuid = session[:authentication_token] || cookies[:authentication_token]
    @current_user ||= User.find_by_uuid(uuid)
  end

  def logged_in?
    # if current_user returns nil, we'll get an error,
    # so let's rescue that and return false since no
    # one is logged in
    current_user.persisted? rescue false
  end
end