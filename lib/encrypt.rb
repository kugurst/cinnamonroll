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

    def self.generate_aes_key
      cipher = OpenSSL::Cipher.new(AES_METHOD)
      cipher.encrypt
      cipher.random_key
    end
  end


  module RSA
    # Given a base64 encoded modulus and exponent (which decode into their string value, not an actual binary number), returns a OpenSSL::PKey::RSA instance with a properly initiated public key (no guarantee on the private key)
    def self.reconstruct_rsa_pub_key(n64, e64)
      n = Base64.decode64 n64
      e = Base64.decode64 e64

      bn = OpenSSL::BN.new n
      be = OpenSSL::BN.new e

      orsa = OpenSSL::PKey::RSA.new

      orsa.n = bn
      orsa.e = be

      orsa
    end
  end

  class Password
    class << self
      PasswordHash.singleton_methods.each do |m|
        define_method m, PasswordHash.method(m).to_proc
      end
    end
  end

end
