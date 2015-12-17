class UsersController < ApplicationController
  include SessionHelper
  include UsersHelper

    before_action :set_user, only: [:show, :edit, :update, :destroy, :confirm, :send_confirm]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    set_return_point_to_referrer
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    return request_aes_key if decrypt_sym!(:user).nil?
    remember_me = if enc_active?
                    Encrypt::AES.decrypt_from_base64 params[:enc][:remember_me], aes_params[IV_PARAM], session[AES_KEY_PARAM]
                  else
                    params[:remember_me]
                  end
    up = user_params
    @user = User.new(up)

    respond_to do |format|
      if @user.save
        log_in @user
        remember @user if remember_me == '1'
        send_confirmation_email_to @user
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: { url: return_point_if_none(root_path), notice: 'user created successfully<br>check your email for a confirmation email' }, status: :created }
      else
        format.html { render :new }
        format.json { render json: { error: @user.errors }, status: :unprocessable_entity }
      end
    end
  end

  def confirm
    if params[:confirmation_token] == @user.confirmation_token
      @user.set email_confirmed: true
      @user.set confirmation_token: SecureRandom.urlsafe_base64(64)
      session[:notice] = "successfully confirmed email"
      redirect_to root_path
    else
      render nothing: true, status: :gone
    end
  end

  def send_confirm
    begin
      set_return_point URI(request.referer).path
    rescue
    end
    rp = return_point_if_none root_path
    rp = root_path if rp == new_user_path
    if @user.nil?
      session[:notice_error] = 'user not found'
      redirect_to rp
    else
      send_confirmation_email_to @user
      session[:notice] = 'confirmation email sent'
      redirect_to rp
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      begin
        @user = User.find_by name: params[:id]
      rescue Mongoid::Errors::DocumentNotFound
        begin
          @user = User.find_by email: params[:id]
        rescue Mongoid::Errors::DocumentNotFound
          @user = nil
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      enc_require(:user).permit(:name, :email, :password)
    end
end
