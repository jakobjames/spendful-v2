class ApplicationController < ActionController::Base
  include AuthenticationMethods
  include MoneyHelper

  protect_from_forgery

  before_filter :authenticate_user, :check_subscription, :https_redirect
  
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

  private

  def https_redirect
    if ENV["ENABLE_HTTPS"] == "yes"
      if request.ssl? && !use_https? || !request.ssl? && use_https?
        protocol = request.ssl? ? "http" : "https"
        flash.keep
        redirect_to protocol: "#{protocol}://", status: :moved_permanently
      end
    end
  end

  def use_https?
    true # Override in other controllers
  end

end
