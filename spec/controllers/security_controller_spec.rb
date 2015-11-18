require "rails_helper"

describe SecurityController, '#post_rsa_key' do
  context 'when not all RSA parameters are provided' do
    it 'responds with :bad_request when no parameters are provided' do
      post :post_rsa_key


      expect(response.status).to eq 400
    end

    it 'responds with :bad_request when only the modulus is provided' do
      params = { ApplicationController::RSA_PARAM => {
                 ApplicationController::MODULUS_PARAM => SecureRandom.urlsafe_base64 } }

      post :post_rsa_key, params


      expect(response.status).to eq 400
    end

    it 'responds with :bad_request when only the exponent is provided' do
      params = { ApplicationController::RSA_PARAM => {
                 ApplicationController::EXPONENT_PARAM => SecureRandom.urlsafe_base64 } }

      post :post_rsa_key, params


      expect(response.status).to eq 400
    end
  end

  context 'when all RSA parameters are provided' do
    it 'responds with :bad_request if the provided parameters cannot perform encryption' do
      params = { ApplicationController::RSA_PARAM => {
                 ApplicationController::EXPONENT_PARAM => SecureRandom.urlsafe_base64,
                 ApplicationController::MODULUS_PARAM => SecureRandom.urlsafe_base64 } }

      post :post_rsa_key, params


      expect(response.status).to eq 400
    end

    it 'responds with 200 if the provided parameters can perform encryption' do
      rsa_key = OpenSSL::PKey::RSA.new 2048

      n64 = Base64.strict_encode64 rsa_key.n.to_s
      e64 = Base64.strict_encode64 rsa_key.e.to_s

      params = { ApplicationController::RSA_PARAM => {
                   ApplicationController::EXPONENT_PARAM => e64,
                   ApplicationController::MODULUS_PARAM => n64 } }


      post :post_rsa_key, params


      expect(response.status).to eq 200
    end
  end
end

describe SecurityController, '#get_aes_key' do
  context 'when no RSA key is present' do
    it 'responds with :failed_dependency' do
      get :get_aes_key


      expect(response.status).to be 424
    end
  end

  context 'when a valid RSA key is present' do
    before :each do
      @rsa_key = OpenSSL::PKey::RSA.new 2048

      @n64 = Base64.strict_encode64 @rsa_key.n.to_s
      @e64 = Base64.strict_encode64 @rsa_key.e.to_s

      params = { ApplicationController::RSA_PARAM => {
                   ApplicationController::EXPONENT_PARAM => @e64,
                   ApplicationController::MODULUS_PARAM => @n64 } }


      post :post_rsa_key, params


      expect(response.status).to eq 200
    end

    context 'when the data type is not JSON' do
      it 'responds with nothing' do
        get :get_aes_key


        expect(response.body).to be_empty
      end
    end

    context 'when the data type is JSON' do
      it 'responds with a properly encrypted AES key' do
        get :get_aes_key, format: :json


        expect(response.body).to_not be_empty


        rep_json = JSON.parse response.body
        ra128 = rep_json[ApplicationController::AES_KEY_PARAM.to_s]
        ra64 = Base64.decode64 ra128

        a64 = @rsa_key.private_decrypt ra64
        expect(a64).to_not be_empty

        aes_key = Base64.decode64 a64
        expect(aes_key).to_not be_empty
      end
    end
  end
end
