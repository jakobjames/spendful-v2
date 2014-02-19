class PasswordsController < ApplicationController
  
  skip_before_filter :authenticate_user, :check_subscription

  def new
  end

  def create
    session[:email] = params[:email].downcase
    @user = User.find_by_email(session[:email])
    if @user.present?
      if @user.password_token.nil?
        @user.update_attribute(:password_token, new_password_token)
      end
      UserMailer.reset_password(@user).deliver
      flash[:notice] = "Instructions have been emailed to you."
      redirect_to login_path
    else
      flash.now[:alert] = "That email address isn't registered."
      render "new"
    end
  end

  def show
    @user = User.where("password_token = ?", params[:id]).first
    redirect_to root_url unless @user
  end

  def update
    @user = User.where("password_token = ?", params[:id]).first
    if @user && !params[:password].empty?
      if @user.update_attributes({:password => params[:password], :password_token => nil})
        redirect_to login_path, :notice => "Your password has been changed."
      else
        flash.now[:alert] = "Could not save your password."
        render "show"
      end
    else
      flash.now[:alert] = "Please enter a new password."
      render "show"
    end
  end
  
  private

  def new_password_token
    token = SecureRandom.base64(10).tr('+/=', 'xyz')
    user = User.where("password_token = ?", token).first
    user ? new_password_token : token
  end

end
