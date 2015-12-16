class MailWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find_by id: user_id
    UsersMailer.confirm_email(user).deliver_now
  end
end
