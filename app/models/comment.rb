class Comment
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  DELETED_STR = '[deleted]'

  field :body, type: String
  field :deleted, type: Boolean, default: false
  field :total_comments, type: Integer, default: 1
  field :nesting_level, type: Integer, default: 0
  field :post_id, type: BSON::ObjectId
  field :user_id, type: BSON::ObjectId
  # belongs_to :post, inverse_of: :comment, polymorphic: true, autosave: true

  # recursively_embeds_many
  embeds_many :comments, as: :com_thread, cyclic: true, cascade_callbacks: true, after_add: [:increment_total_and_chain, :set_child_post, :set_nesting_level], after_remove: :decrement_total_and_chain
  embedded_in :com_thread, cyclic: true
  # accepts_nested_attributes_for :child_comments, polymorphic: true

  index post_id: 1

  validates :body, :post_id, :user_id, :nesting_level, :total_comments, presence: true

  before_destroy :delete_comment

  def post
    @post ||= Post.find_by id: post_id
  end

  def post=(post)
    set post_id: post.id
  end

  def post_id=(post_id)
    @post = Post.find_by id: post_id
    super post_id
  end

  def user
    @user ||= User.find_by id: user_id
  end

  def user=(user)
    set user_id: user.id
  end

  def user_id=(user_id)
    @user = User.find_by id: user_id
    super user_id
  end

  def body
    deleted ? DELETED_STR : super
  end

  def delete_comment
    set deleted: true
    false
  end

  def undelete_comment
    set deleted: false
  end

  def increment_total_and_chain(com)
    inc total_comments: 1
    com_thread.try :increment_total_and_chain, com
  end

  def set_child_post(com)
    com.post = post if post
  end

  def set_nesting_level(com)
    com.set nesting_level: nesting_level + 1
  end

  def decrement_total_and_chain(com)
    inc total_comments: -1
    com_thread.try :decrement_total_and_chain, com
  end
end
