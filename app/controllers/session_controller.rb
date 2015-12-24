class SessionController < ApplicationController
  layout 'session/session'
  include SessionHelper

  BAD_COMBO_MSG = "Username/email and password combination not found"

  def new
    begin
      set_return_point URI(request.referer).path
    rescue
    end
    if logged_in?
      flash[:notice] = "Already logged in"
      rp = return_point_if_none root_path
      rp = root_path if rp == login_path
      redirect_to rp
    end
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
        respond_to do |format|
          format.html do
            flash.now[:error] = BAD_COMBO_MSG
            render 'new', status: :not_found
          end
          format.json do
            msg = { error: BAD_COMBO_MSG }
            render json: msg, status: :not_found
          end
        end
        return
      end
    end

    if user && user.valid_pass?(lp[:password])
      # Log the user in and redirect to the user's show page.
      log_in user
      remember user if lp[:remember_me] == '1'
      respond_to do |format|
        format.html do
          flash[:notice] = "Log in successful!"
          redirect_to return_point_if_none user
        end
        format.json do
          msg = { url: return_point_if_none(user), notice: 'logged in successfully' }
          render json: msg
        end
      end
    else
      respond_to do |format|
        format.html do
          flash[:error] = BAD_COMBO_MSG
          render 'new', status: :not_found
        end
        format.json do
          msg = { error: BAD_COMBO_MSG }
          render json: msg, status: :not_found
        end
      end
    end
  end

  def destroy
    begin
      set_return_point URI(request.referer).path
    rescue
    end
    log_out if logged_in?
    redirect_to return_point_if_none root_url
  end

  private
    def login_params
      enc_require(:session).permit(:password, :email_or_username, :remember_me)
    end
end
