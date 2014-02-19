class UserMailer < ActionMailer::Base

  include MailerHelper

  default from: "Mitchell Bryson <mitchell@spendful.com>"

  def signup(user)
    @user = user
    @url = url + login_path
    mail(:to => user.email,
           :subject => "Created your Spendful.com account.")
  end

  def reset_password(user)
    @user = user
    @url  = url + reset_password_path + "/" + @user.password_token
    mail(:to => user.email,
           :subject => "Reset your Spendful password.")
  end

  def feedback(user, feedback)
    @user = user
    @feedback = feedback
    mail(:to => "help@spendful.com",
          :from => user.email,
          :subject => "Spendful.com feedback.")
  end

  def destroy(user)
    @user = user
    mail(:to => user.email,
           :subject => "Your Spendful.com log in has been deleted.")
  end

end
