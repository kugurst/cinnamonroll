class NameNotLikeEmailValidator < ActiveModel::Validator
  def validate(record)
    if record.name =~ /.+@.+\..+/i
      record.errors[:name] << "user names can't be like emails"
    end
  end
end

class User
  include Mongoid::Document
  include Sunspot::Mongo

  # searchable do
    field :name, type: String
    field :email, type: String
    has_many :comments
  # end
  # The password will be stored as a base64 hash
  field :password, type: String
  field :remember_hash, type: Hash

  validates :password, presence: true
  validates :email, :name, uniqueness: true, presence: true, case_sensitive: false
  validates_length_of :remember_hash, maximum: 10
  validates_with NameNotLikeEmailValidator

  before_validation :trim_remember_hash, on: :update

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def trim_remember_hash
    remember_hash.delete remember_hash.keys.map{|e| e.to_i}.min.to_s if remember_hash.length > 10
  end

  def remember_hash
    @remember_hash ||= self[:remember_hash].nil? ? {} : self[:remember_hash].clone
  end

  def password=(pass)
    super Encrypt::Password.createHash pass
  end

  def email=(em)
    super em.downcase()
  end

  def valid_pass?(test_pass)
    Encrypt::Password.validatePassword test_pass, password
  end

  def remember
    new_tok = User.new_token
    remember_hash[Time.now.to_i] = Encrypt::Password.createHash(new_tok)
    update_attributes! remember_hash: remember_hash
    new_tok
  end

  def forget(tok)
    update_attributes! remember_hash: remember_hash.delete_if { |k, v| Encrypt::Password.validatePassword tok, v } unless tok.nil?
  end

  def valid_rem?(test_tok)
    ret = false
    remember_hash.values.each do |correct_rem|
      ret = true if Encrypt::Password.validatePassword test_tok, correct_rem
    end
    ret
  end
end
