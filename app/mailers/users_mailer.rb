class UsersMailer < ApplicationMailer

  def confirm_email(user)
    @user = user
    mail to: "@#{@user.name} <#{@user.email}>", reply_to: 'bot.markaligbe+noreply@gmail.com', subject: 'Welcome to Mark Aligbe.com'
  end
end
