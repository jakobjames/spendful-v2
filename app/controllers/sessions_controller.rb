class SessionsController < ApplicationController
  
  skip_before_filter :authenticate_user, :except => :destroy
  skip_before_filter :check_subscription

  def new
    redirect_to budgets_path if self.logged_in?
  end

  def create
		self.reset_current_user
    user, message = User.authenticate(params[:email], params[:password])
    if user
      # TODO: set remember me token, if present
      flash[:notice] = message
      self.current_user = user
      redirect_to budgets_path
    else
      flash[:alert] = message
      render :new
    end
  end

  def destroy
    self.reset_current_user
    flash[:notice] = Constants::Users::LOGOUT_SUCCESSFUL
    redirect_to root_path
  end
end
