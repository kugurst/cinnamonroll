class Comment
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  field :body, type: String
  belongs_to :user
  belongs_to :post
  # recursively_embeds_many
  has_many :child_comments, class_name: "Comment", autosave: true, dependent: :destroy
  belongs_to :parent_comment, class_name: "Comment"

  validates :body, :user, :post, presence: true
end
