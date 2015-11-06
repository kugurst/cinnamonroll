class SecurityController < ApplicationController
  # same constant as in encrypt.coffee
  RSA_KEY_PARAM = :rsa_key
  AES_KEY_PARAM = :aes_key
  RSA_MODULUS_PARAM = :n
  RSA_EXPONENT_PARAM = :e

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
      begin
        session[RSA_KEY_PARAM] = SecurityHelper.reconstruct_rsa_pub_key rkp[RSA_MODULUS_PARAM], rkp[RSA_EXPONENT_PARAM]
      rescue
        head 420
      else
        render nothing: true
      end
    end
  end

  def get_aes_key
    k64 = Base64.strict_encode64 SecurityHelper.generate_aes_key
    session[AES_KEY_PARAM] = k64
    jeb = Jbuilder.new do |json|
      json.set! AES_KEY_PARAM, k64
    end
    render plain: jeb.target!
  end

  private
    def rsa_key_params
      params.require(RSA_KEY_PARAM).permit(:n, :e)
    end
end
