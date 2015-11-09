module SessionHelper

  def log_in(user)
    session[:user_id] = user.id.to_s
  end
end
