class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # before_action :require_aes_key!

  def hello
    render text: "hello, world!"
  end

  # require_dependency Rails.root.join('vendor/PasswordHash.rb')

  BANNER = "********************************"

  private
  def require_aes_key!(ret_point = request.url)
    set_return_point ret_point
    SecurityHelper.require_aes_key session, request, self
  end

  def set_return_point(path, overwrite = false)
    if overwrite or session[:return_point].blank?
      session[:return_point] = path
    end
  end

  def return_point
    ret = session[:return_point] || root_path
    session.delete :return_point
    ret
  end
end
