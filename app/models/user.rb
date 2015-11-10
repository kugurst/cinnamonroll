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

  attr_accessor :remember_token

  # searchable do
    field :name, type: String
    field :email, type: String
  # end
  # The password will be stored as a base64 hash
  field :password, type: String
  field :remember_hash, type: String

  validates :password, presence: true
  validates :email, :name, uniqueness: true, presence: true, case_sensitive: false
  validates_with NameNotLikeEmailValidator

  def self.new_token
    SecureRandom.urlsafe_base64
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
    self.remember_token = User.new_token
    update_attribute :remember_hash, Encrypt::Password.createHash(remember_token)
  end

  def forget
    update_attribute(:remember_hash, nil)
  end

  def valid_rem?(test_tok)
    return false if remember_hash.nil?
    Encrypt::Password.validatePassword test_tok, remember_hash
  end
end
