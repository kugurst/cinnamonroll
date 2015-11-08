module Encrypt
  module AES
    AES_METHOD = 'AES-256-CBC'

    def self.deep_hash_decrypt h, cipher, raw_key, raw_iv
      h.each do |k, v|
        if v.is_a? Hash
          deep_hash_decrypt v
        elsif v.is_a? Array
          deep_array_decrypt v
        else
          # It's probably a string.
          cipher.reset
          cipher.decrypt
          cipher.key = raw_key
          cipher.iv = raw_iv
          h[k] = cipher.update(Base64.decode64 v) + cipher.final
        end
      end
    end

    def self.deep_array_decrypt a, cipher, raw_key, raw_iv
      a.map! do |e|
        if e.is_a? Hash
          deep_hash_decrypt e
          e
        elsif e.is_a? Array
          deep_array_decrypt e
          e
        else
          cipher.reset
          cipher.decrypt
          cipher.key = raw_key
          cipher.iv = raw_iv
          cipher.update(Base64.decode64 e) + cipher.final
        end
      end
    end

    def self.decrypt_from_base64(str, iv, key)
      cipher = OpenSSL::Cipher.new(AES_METHOD)
      cipher.decrypt
      cipher.key = Base64.decode64 key
      cipher.iv = Base64.decode64 iv

      cipher.update(Base64.decode64 str) + cipher.final
    end

    def self.encrypt_to_base64(dat, iv, key)
      cipher = OpenSSL::Cipher.new(AES_METHOD)
      cipher.encrypt
      cipher.key = Base64.decode64 key
      cipher.iv = Base64.decode64 iv

      Base64.encode64(cipher.update(dat) + cipher.final)
    end

    def self.generate_aes_key
      cipher = OpenSSL::Cipher.new(AES_METHOD)
      cipher.encrypt
      cipher.random_key
    end

    def self.decrypt_params_from_base64!(params, iv, key)
      cipher = OpenSSL::Cipher.new(AES_METHOD)
      pkey = Base64.decode64 key
      piv = Base64.decode64 iv

      deep_hash_decrypt params, cipher, pkey, piv
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
