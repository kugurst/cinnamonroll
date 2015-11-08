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
  # end
  # The password will be stored as a base64 hash
  field :password, type: String

  validates :password, uniqueness: true, presence: true
  validates :email, :name, uniqueness: true, presence: true, case_sensitive: false
  validates_with NameNotLikeEmailValidator


  def password=(pass)
    super Encrypt::Password.createHash pass
  end

  def email=(em)
    super em.downcase()
  end

  def valid_pass?(test_pass)
    Encrypt::Password.validatePassword test_pass, password
  end

end
