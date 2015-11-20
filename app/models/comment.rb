class Comment
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  DELETED_STR = '[deleted]'

  field :body, type: String
  field :deleted, type: Boolean, default: false
  belongs_to :user, polymorphic: true
  belongs_to :post, inverse_of: :comment, polymorphic: true, autosave: true

  # recursively_embeds_many
  embeds_many :comments, as: :com_thread, after_add: :set_child_post, cyclic: true
  embedded_in :com_thread, cyclic: true, polymorphic: true
  # accepts_nested_attributes_for :child_comments, polymorphic: true
  # has_many :child_comments, class_name: "Comment", autosave: true, after_add: :set_child_post
  # belongs_to :parent_comment, class_name: "Comment"

  validates :body, :user, :post, presence: true

  before_destroy :delete_comment

  def body
    deleted ? DELETED_STR : super
  end

  def user=(user)
    self[:user] = user.id
  end

  def post=(post)
    self[:post] = post.id
    post.comments << self
  end

  def get_user
    deleted ? User.deleted_user : user
  end

  def delete_comment
    update_attributes deleted: true
    false
  end

  def set_child_post(child)
    child.post = post if post
  end
end
