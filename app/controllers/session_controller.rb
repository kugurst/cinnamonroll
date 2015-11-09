class SessionController < ApplicationController
  layout 'session/session'
  include SessionHelper

  def new
  end

  def create
    return request_aes_key if decrypt_sym!(:session).nil?
    lp = login_params

    begin
      user = User.find_by email: lp[:email_or_username].downcase
    rescue Mongoid::Errors::DocumentNotFound
      begin
        user = User.find_by name: lp[:email_or_username]
      rescue Mongoid::Errors::DocumentNotFound
        flash.now[:error] = "Username/email and password combination not found"
        render 'new', status: :not_found
        return
      end
    end

    if user && user.valid_pass?(lp[:password])
      # Log the user in and redirect to the user's show page.
      log_in user
      flash[:notice] = "Log in successful!"
      redirect_to user
    else
      flash[:error] = "Username/email and password combination not found"
      render 'new', status: :not_found
    end
  end

  def destroy
  end

  private
    def login_params
      enc_require(:session).permit(:password, :email_or_username)
    end
end
