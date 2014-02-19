class ApplicationController < ActionController::Base
  include AuthenticationMethods
  include MoneyHelper

  protect_from_forgery

  before_filter :authenticate_user, :check_subscription
  
  def current_user=(user)
    @current_user = user
    session[:authentication_token] = user.uuid
    cookies[:authentication_token] = user.uuid
  end
  
  def reset_current_user
    @current_user = nil
    cookies.delete(:authentication_token)
    reset_session
  end

  def authenticate_user
    unless self.logged_in?
      flash[:notice] = Constants::Users::PLEASE_LOG_IN
      redirect_to login_path
    end
  end
  
  def check_subscription
    unless current_user.trial? || current_user.premium?
      redirect_to new_subscription_path
    end
  end

end
