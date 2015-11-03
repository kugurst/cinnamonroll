module Encrypt
  module AES
    AES_METHOD = 'AES-256-CBC'

    @@cipher = OpenSSL::Cipher.new(AES_METHOD)

    def self.decrypt_base64(str, iv, key)
      @@cipher.reset
      @@cipher.decrypt
      @@cipher.key = Base64.decode64 key
      @@cipher.iv = Base64.decode64 iv

      @@cipher.update(Base64.decode64 str) + @@cipher.final
    end

    #
    def self.encrypt(dat, iv, key)
      @@cipher.reset
      @@cipher.encrypt
      @@cipher.key = Base64.decode64 key
      @@cipher.iv = Base64.decode64 iv

      Base64.encode64(@@cipher.update(dat) + @@cipher.final)
    end
  end
end
