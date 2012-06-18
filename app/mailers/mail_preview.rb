class MailPreview < MailView
  
  def signup
    @user = User.order("RANDOM()").first
    UserMailer.signup(@user) 
  end
  
  def reset_password
    @user = User.order("RANDOM()").first
    @user.password_token = "ABC123"
    UserMailer.reset_password(@user) 
  end
  
  def feedback
    @user = User.order("RANDOM()").first
    UserMailer.feedback(@user, "I think Spendful is bloody rubbish!") 
  end
  
  def destroy
    @user = User.order("RANDOM()").first
    UserMailer.destroy(@user) 
  end
  
end
