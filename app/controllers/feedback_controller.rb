class FeedbackController < ApplicationController
  
  skip_before_filter :check_subscription

  def create
    @user = current_user
    @feedback = @user.feedbacks.new({:message => params[:message]})
    redirect = budgets_path
    redirect = request.referer if request.referer
    
    if @feedback.save
      UserMailer.feedback(@user, @feedback.message).deliver
    end
    flash[:notice] = 'Thanks for your feedback! Feel free to send us more.'
    redirect_to redirect
  end

end
