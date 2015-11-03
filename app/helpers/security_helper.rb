module SecurityHelper
  def self.require_aes_key ( session, request, cont )
    unless session.key? :aes_key
      pair = OpenSSL:PKey::RSA.generate 2048
      cont.send :redirect_to, {controller: 'security', action: 'new'}

    end
  end
end
