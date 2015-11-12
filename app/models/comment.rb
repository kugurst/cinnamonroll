class Comment
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  field :body, type: String
  belongs_to :user, dependent: :destroy
  belongs_to :post, dependent: :destroy
  has_and_belongs_to_many :comments
end
