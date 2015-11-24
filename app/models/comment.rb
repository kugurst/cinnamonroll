class Comment
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  DELETED_STR = '[deleted]'

  field :body, type: String
  field :deleted, type: Boolean, default: false
  field :total_comments, type: Integer, default: 1
  field :nesting_level, type: Integer, default: 0
  field :deepest_nesting_level, type: Integer, default: 0
  field :post_id, type: BSON::ObjectId
  field :user_id, type: BSON::ObjectId

  embeds_many :comments, as: :com_thread, cyclic: true, cascade_callbacks: true, after_add: [:increment_total_and_chain, :set_child_post, :set_nesting_level], after_remove: :decrement_total_and_chain
  embedded_in :com_thread, cyclic: true
  # accepts_nested_attributes_for :child_comments, polymorphic: true

  index post_id: 1, id: 1

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
    update_deepest_nesting_level 1
  end

  def update_deepest_nesting_level(level)
    if level > deepest_nesting_level
      self.deepest_nesting_level = level
      com_thread.try :update_deepest_nesting_level, level + 1
    end
  end

  def decrement_total_and_chain(com)
    inc total_comments: -1
    com_thread.try :decrement_total_and_chain, com
  end

  ### from: http://stackoverflow.com/questions/14370609/mongoid-querying-embedded-recursively-embeds-many-documents ###
  # 'n' is the maximum level of recursion to check.
  def self.each_matching_comment(q, &block)
    queries = 0.upto(deepest_nesting_level).collect { |l| level_n_query(q) }
    Comment.or(*queries).each { |c| puts c }
  end

  def self.level_n_query(q)
    key = 'comments.' * deepest_nesting_level + '_id'
    return {key => q}
  end

  # recursive, returns array of all subcomments that match q including self
  def each_matching_subcomment(q, &block)
    yield self if self.id == q
    self.comments.each { |c| c.each_matching_subcomment(q, &block) }
  end
  ######
end
