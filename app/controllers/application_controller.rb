class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  before_action :require_aes_key

  def hello
    render text: "hello, world!"
  end

  # require_dependency Rails.root.join('vendor/PasswordHash.rb')

  BANNER = "********************************"

  private
  def require_aes_key
    SecurityHelper.require_aes_key session, request
  end
end
