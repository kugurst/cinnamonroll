class UsersMailer < ApplicationMailer

  def confirm_email(user)
    @user = user
    mail to: @user.email, subject: 'Welcome to Mark Aligbe.com'
  end
end
