module SessionHelper

  def log_in(user)
    session[:user_id] = user.id.to_s
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    forget current_user
    session.delete :user_id
    @current_user = nil
  end

  def remember(user)
    tok = user.remember
    cookies.permanent.signed[:user_id] = user.id.to_s
    cookies.permanent.signed[:remember_token] = tok.to_s
  end

  def forget(user)
    user.forget cookies.signed[:remember_token]
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def current_user
    if (user_id = session[:user_id])
      begin
        @current_user ||= User.find_by(id: user_id)
      rescue Mongoid::Errors::DocumentNotFound
        session.delete :user_id
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
        @current_user = nil
      end
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.valid_rem?(cookies.signed[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
end
