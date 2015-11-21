class Comment
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  DELETED_STR = '[deleted]'

  field :body, type: String
  field :deleted, type: Boolean, default: false
  field :nesting_level, type: Integer, default: 0
  belongs_to :user, autosave: true
  belongs_to :post, autosave: true
  belongs_to :parent_comment, class_name: "Comment", autosave: true
  has_many :comments, after_add: [:set_child_post, :set_nesting_level]

  validates :body, :user, :post, presence: true

  before_destroy :delete_comment

  def body_with_delete
    deleted ? DELETED_STR : body_without_delete
  end

  def user_with_delete
    deleted ? User.deleted_user : user_without_delete
  end

  alias_method_chain :user, :delete
  alias_method_chain :body, :delete

  def delete_comment
    set deleted: true
    false
  end

  def undelete_comment
    set deleted: false
  end

  def set_child_post(child)
    child.set post: post if post && !child.post
  end

  def set_nesting_level(child)
    child.set nesting_level: nesting_level + 1
  end
end
