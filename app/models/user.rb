class NameNotLikeEmailValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:name] << "user names can't be like emails" \
                            if record.name =~ /.+@.+\..+/i
  end
end
class PasswordCheckValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:password] << "your password is too weak" if !record.good_password
  end
end
class NotDeletedUserValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.nil?
      record.errors[:name] << "nice try" if record.name.downcase == User::DELETED_NAME
    end
    record.errors[:email] << "nice try" if record.email == User::DELETED_EMAIL
  end
end

class User
  include Mongoid::Document
  include Sunspot::Mongo
  include GlobalID::Identification

  MAX_REMEMBERED_DEVICES = 10

  DELETED_NAME = 'not@your.business'
  DELETED_EMAIL = 'who.cares@anyway.com'
  DELETED_PASSWORD = "go ahead and try"

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def self.deleted_user
    @@deleted_user ||= User.new name: DELETED_NAME, email: DELETED_EMAIL, password: DELETED_PASSWORD
  end

  # searchable do
    field :name, type: String
    field :email, type: String
    field :email_confirmed, type: Boolean, default: false
    field :confirmation_token, type: String, default: -> { SecureRandom.urlsafe_base64 64 }
    has_many :comments, dependent: :destroy
  # end
  # The password will be stored as a base64 hash
  field :password, type: String
  field :remember_hash, type: Hash, default: {}

  validates :password, presence: true
  validates :email, :name, uniqueness: true, presence: true, case_sensitive: false
  validates_length_of :remember_hash, maximum: 10
  validates_with NameNotLikeEmailValidator, PasswordCheckValidator, NotDeletedUserValidator

  before_validation :trim_remember_hash, on: :update

  index name: 1, email: 1

  attr_accessor :good_password
  def good_password
    if @good_password.nil?
      true
    else
      @good_password
    end
  end

  # Automatically encrypt the password on save
  def password=(pass)
    @good_password = false if system("look \"#{pass.downcase}\" > /dev/null 2>&1")
    super Encrypt::Password.createHash pass
  end

  # Emails are case insensitive
  def email=(em)
    super em.downcase
  end

  # Simplify password checking. Takes a plain string password
  def valid_pass?(test_pass)
    Encrypt::Password.validatePassword test_pass, password
  end

  # Creates a new token and adds it to the list of remembered tokens
  def remember
    new_tok = User.new_token
    # Convert times to System.nanoTime(), Java style
    time = (Time.now.to_f * 10**9).to_i.to_s
    remember_hash[time] = Encrypt::Password.createHash(new_tok)
    update_attributes! remember_hash: remember_hash
    new_tok
  end

  # Removes the specified token from the list of remembered tokens. Runs in
  # fixed time
  def forget(tok)
    update_attributes! remember_hash: remember_hash.delete_if { |_k, v| Encrypt::Password.validatePassword tok, v }  unless tok.nil?
  end

  def forget_all!
    update_attributes! remember_hash: {}
  end

  # Determines if the specified token is remembered. Runs in fixed time
  def valid_rem?(test_tok)
    ret = false
    remember_hash.values.each do |correct_rem|
      ret = true if Encrypt::Password.validatePassword test_tok, correct_rem
    end
    ret
  end

  def to_param
    name
  end

  private

  def trim_remember_hash
    remember_hash.delete remember_hash.keys.map{|e| e.to_i}.min.to_s if remember_hash.length > MAX_REMEMBERED_DEVICES
  end
end
