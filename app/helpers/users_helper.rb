module UsersHelper
  def self.generate_user_confirmation_token(user)
    user.set confirmation_token: SecureRandom.urlsafe_base64(64)
  end

  def send_confirmation_email_to(user)
    UsersHelper.generate_user_confirmation_token user

    MailWorker.perform_async user.id.to_s
    # UsersMailer.delay.confirm_email(user)
  end
end
