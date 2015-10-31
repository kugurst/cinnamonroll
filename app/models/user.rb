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

  searchable do
    field :name, type: String
    field :email, type: String
  end
  # The password will be stored as a base64 hash
  field :password, type: String

  validates :name, :email, :password, uniqueness: true, presence: true
  validates_with NameNotLikeEmailValidator

end
