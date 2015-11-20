class Comment
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  DELETED_STR = '[deleted]'

  field :body, type: String
  field :deleted, type: Boolean, default: false
  # belongs_to :post, inverse_of: :comment, polymorphic: true, autosave: true

  # recursively_embeds_many
  embeds_many :comments, as: :com_thread, cyclic: true, cascade_callbacks: true
  embedded_in :com_thread, cyclic: true
  # accepts_nested_attributes_for :child_comments, polymorphic: true

  validates :body, presence: true

  before_destroy :delete_comment

  def body
    deleted ? DELETED_STR : super
  end

  def delete_comment
    set deleted: true
    false
  end
end
