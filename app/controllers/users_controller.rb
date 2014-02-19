class UsersController < ApplicationController
  
  skip_before_filter :authenticate_user, :only => [:new, :create]
  skip_before_filter :check_subscription

  def new
    redirect_to budgets_path and return if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      self.current_user = @user
      flash[:notice] = Constants::Users::WELCOME_MESSAGE
      redirect_to new_onboarding_path
    else
      render :new
    end
  end

  def edit
    @user = self.current_user
  end

  def update
    @user = self.current_user
    if @user.update_attributes(params[:user])
      self.current_user = @user
      flash[:notice] = Constants::Users::DETAILS_UPDATED
      redirect_to account_path
    else
      render :edit
    end
  end

  def destroy
    user = self.current_user
    user.destroy
    reset_current_user
    flash[:notice] = Constants::Users::ACCOUNT_DELETED
    redirect_to root_path
  end

end
