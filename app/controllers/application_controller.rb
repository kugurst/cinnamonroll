class ApplicationController < ActionController::Base
  # same constant as in encrypt.coffee
  RSA_PARAM = :rsa
  AES_PARAM = :aes
  IV_PARAM = :iv
  KEY_PARAM = :key
  AES_KEY_PARAM = :"#{AES_PARAM}_#{KEY_PARAM}"
  RSA_KEY_PARAM = :"#{RSA_PARAM}_#{KEY_PARAM}"
  MODULUS_PARAM = :modulus
  EXPONENT_PARAM = :exponent
  ENC_PARAM = :enc
  ACTIVE_PARAM = :active

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

    def rsa_key_params
      params.require(RSA_PARAM).permit(MODULUS_PARAM, EXPONENT_PARAM)
    end

    def enc_params
      params.require(ENC_PARAM).permit(ACTIVE_PARAM)
    end

    def aes_params
      params.require(AES_PARAM).permit(IV_PARAM)
    end

    # If this is present in the params, then the client is saying the form is in plain form
    def enc_active?
      if params.key? ENC_PARAM
        !enc_params().key?(ACTIVE_PARAM)
      else
        true
      end
    end
end
