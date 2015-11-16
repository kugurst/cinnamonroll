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


  # Model methods
  # Avoiding nil errors on creation, while also avoiding overwriting the value in the database. Is there a better way to do this?
  def remember_hash
    @remember_hash ||= self[:remember_hash].nil? ? {} : self[:remember_hash].clone
  end

  # Automatically encrypt the password on save
  def password=(pass)
    super Encrypt::Password.createHash pass
  end

  # Emails are case insensitive
  def email=(em)
    super em.downcase()
  end

  # Simplify password checking. Takes a plain string password
  def valid_pass?(test_pass)
    Encrypt::Password.validatePassword test_pass, password
  end

  # Creates a new token and adds it to the list of remembered tokens
  def remember
    new_tok = User.new_token
    remember_hash[Time.now.to_i] = Encrypt::Password.createHash(new_tok)
    update_attributes! remember_hash: remember_hash
    new_tok
  end

  # Removes the specified token from the list of remembered tokens. Runs in fixed time
  def forget(tok)
    update_attributes! remember_hash: remember_hash.delete_if { |k, v| Encrypt::Password.validatePassword tok, v } unless tok.nil?
  end

  # Determines if the specified token is remembered. Runs in fixed time
  def valid_rem?(test_tok)
    ret = false
    remember_hash.values.each do |correct_rem|
      ret = true if Encrypt::Password.validatePassword test_tok, correct_rem
    end
    ret
  end


  # Helper methods
  private
    def self.new_token
      SecureRandom.urlsafe_base64
    end

    def trim_remember_hash
      remember_hash.delete remember_hash.keys.map{|e| e.to_i}.min.to_s if remember_hash.length > 10
    end
end
