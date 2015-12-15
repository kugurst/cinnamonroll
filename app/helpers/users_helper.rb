module UsersHelper
  def self.generate_user_confirmation_token(user)
    user.set confirmation_token: SecureRandom.urlsafe_base64(64)
  end

  def self.send_confirmation_email_to(user)
    UsersHelper.generate_user_confirmation_token user

  end
end
