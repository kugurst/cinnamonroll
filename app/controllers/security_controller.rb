class SecurityController < ApplicationController

  skip_before_action :require_aes_key!, only: :new

  def new
    render js: "alert('Hello Rails')"
  end

  def post_rsa_key
    rkp = rsa_key_params

    if !rkp.key?(MODULUS_PARAM) || !rkp.key?(EXPONENT_PARAM)
      head :bad_request
    else
      # Attempt to encrypt with them first
      begin
        rsa_key = Encrypt::RSA.reconstruct_rsa_pub_key rkp[MODULUS_PARAM], rkp[EXPONENT_PARAM]
        rsa_key.public_encrypt SecureRandom.urlsafe_base64

        session[MODULUS_PARAM] = rkp[MODULUS_PARAM]
        session[EXPONENT_PARAM] = rkp[EXPONENT_PARAM]
        render nothing: true
      rescue
        head :bad_request
      end
    end
  end

  def get_aes_key
    responded = false

    k64 = Base64.strict_encode64 Encrypt::AES.generate_aes_key
    session[AES_KEY_PARAM] = k64

    begin
      rsa_key = Encrypt::RSA.reconstruct_rsa_pub_key session[MODULUS_PARAM], session[EXPONENT_PARAM]
      aes_enc = rsa_key.public_encrypt k64
      a64 = Base64.strict_encode64 aes_enc
      jeb = Jbuilder.new do |json|
        json.set! AES_KEY_PARAM, a64
      end

      respond_to do |format|
        format.json { render  plain: jeb.target!; responded = true }
      end
    rescue
      head :failed_dependency
      responded = true
    end

    render nothing: true unless responded
  end

  private

    def rsa_key_params
      params.fetch(RSA_PARAM, {}).permit(MODULUS_PARAM, EXPONENT_PARAM)
    end
end
