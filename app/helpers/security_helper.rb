module SecurityHelper
  def self.require_aes_key ( session, request, cont )
  end

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

  def self.generate_aes_key
    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.encrypt
    cipher.random_key
  end
end
