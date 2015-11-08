class SessionController < ApplicationController
  layout 'session/session'

  def new
  end

  def create
    lp = login_params

    if enc_active?
      ap = aes_params
      Encrypt::AES.decrypt_params_from_base64! lp, ap[IV_PARAM], session[AES_KEY_PARAM]
    end
    puts lp
    begin
      user = User.find_by email: lp[:email_or_username].downcase
    rescue Mongoid::Errors::DocumentNotFound
      begin
        user = User.find_by name: lp[:email_or_username]
      rescue Mongoid::Errors::DocumentNotFound
        flash[:error] = "Username/email or password not found"
        render 'new', status: :not_found
        return
      end
    end

    if user && user.valid_pass?(lp[:password])
      # Log the user in and redirect to the user's show page.
    else
      # Create an error message.
      render 'new'
    end
  end

  def destroy
  end

  private
    def login_params
      params.require(:session).permit(:password, :email_or_username)
    end
end
