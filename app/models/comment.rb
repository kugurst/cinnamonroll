class Comment
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  DELETED_STR = '[deleted]'

  field :body, type: String
  field :deleted, type: Boolean, default: false
  belongs_to :user
  belongs_to :post
  # recursively_embeds_many
  has_many :child_comments, class_name: "Comment", autosave: true, dependent: :destroy
  belongs_to :parent_comment, class_name: "Comment"

  validates :body, :user, :post, presence: true

  def body
    deleted ? DELETED_STR : super
  end

  def get_user
    deleted ? User.deleted_user : user
  end
end
