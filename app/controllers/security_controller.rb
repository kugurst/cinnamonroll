class SecurityController < ApplicationController
  # same constant as in encrypt.coffee
  RSA_KEY_PARAM = :rsa_key
  AES_KEY_PARAM = :aes_key
  RSA_MODULUS_PARAM = :modulus
  RSA_EXPONENT_PARAM = :exponent

  skip_before_action :require_aes_key!, only: :new

  def new
    render js: "alert('Hello Rails')"
  end

  def post_rsa_key
    rkp = rsa_key_params
    puts rkp
    if !rkp.key?(RSA_MODULUS_PARAM) || !rkp.key?(RSA_EXPONENT_PARAM)
      head :bad_request
    else
      session[RSA_MODULUS_PARAM] = rkp[RSA_MODULUS_PARAM]
      session[RSA_EXPONENT_PARAM] = rkp[RSA_EXPONENT_PARAM]
      render nothing: true
    end
  end

  def get_aes_key
    k64 = Base64.strict_encode64 Encrypt::AES.generate_aes_key
    session[AES_KEY_PARAM] = k64
    rsa_key = Encrypt::RSA.reconstruct_rsa_pub_key session[RSA_MODULUS_PARAM], session[RSA_EXPONENT_PARAM]
    aes_enc = rsa_key.public_encrypt k64
    a64 = Base64.strict_encode64 aes_enc
    jeb = Jbuilder.new do |json|
      json.set! AES_KEY_PARAM, a64
    end
    render plain: jeb.target!
  end

  private
    def rsa_key_params
      params.require(RSA_KEY_PARAM).permit(RSA_MODULUS_PARAM, RSA_EXPONENT_PARAM)
    end
end
