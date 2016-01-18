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
  before_action :add_notice

  def default_url_options
    { host: "www.markaligbe.com" }
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  # require_dependency Rails.root.join('vendor/PasswordHash.rb')

  BANNER = "*" * 80

  # Silence the unpermitted message
  ActionController::Parameters.action_on_unpermitted_parameters = false

  private
    def add_notice
      if session.has_key? :notice
        gon.push notice: session[:notice]
        session.delete :notice
      end
      if session.has_key? :notice_error
        gon.push notice_error: session[:notice_error]
        session.delete :notice_error
      end
    end

    def set_return_point(path, overwrite = false)
      if overwrite or session[:return_point].blank?
        session[:return_point] = path
      end
    end

    def return_point
      was_blank = session[:return_point].blank?
      ret = session[:return_point] || root_path
      session.delete :return_point
      return ret, was_blank
    end

    def return_point_if_none(alternate_path)
      return_path, was_blank = return_point
      was_blank ? alternate_path : return_path
    end

    def enc_params
      params.require(ENC_PARAM).permit(ACTIVE_PARAM)
    end

    def aes_params
      params.require(AES_PARAM).permit(IV_PARAM)
    end

    # If this is present in the params, then the client is saying the form is not encrypted
    def enc_active?
      if params.key? ENC_PARAM
        !enc_params().key?(ACTIVE_PARAM)
      else
        true
      end
    end

    # Returns nil if we don't have an AES key for this session but we are supposed to be encrypting
    def decrypt_params!(parms)
      if enc_active?
        if !session.key? AES_KEY_PARAM
          return nil
        else
          Encrypt::AES.decrypt_params_from_base64! parms, aes_params[IV_PARAM], session[AES_KEY_PARAM]
        end
      end
      parms
    end

    def enc_require(sym, parms = params)
      if enc_active?
        parms.require(ENC_PARAM).require(sym)
      else
        parms.require(sym)
      end
    end

    def enc_fetch(sym, parms = params)
      if enc_active?
        parms.fetch(ENC_PARAM, {}).fetch(sym, {})
      else
        parms.fetch(sym, {})
      end
    end

    def decrypt_sym!(sym, parms = params)
      par = enc_require sym, parms
      decrypt_params! par
    end

    def request_aes_key
      head :failed_dependency
    end

    def head_if_true(status, test, msg = nil)
      msg = status.to_s if msg.nil?
      return false unless test
      respond_to do |format|
        format.html { head status }
        format.json { render json: { error: msg }, status: status }
      end
      true
    end

    def set_return_point_to_referrer(overwrite = false)
      # We may not have a valid URI
      begin
        set_return_point URI(request.referer).path, overwrite
      rescue
      end
    end
end
