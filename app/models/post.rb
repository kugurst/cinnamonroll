class Post
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  FILE_PATH = "posts/sources/"
  CATEGORIES = [:review, :project, :thought, :testing]

  field :title, type: String
  field :tags, type: Array, default: []
  field :file_path, type: String
  field :category, type: Symbol, default: :testing
  has_and_belongs_to_many :related_posts, class_name: "Post", autosave: true, after_add: :add_self_to_child
  has_and_belongs_to_many :comment_threads, class_name: "Comment", inverse_of: nil, autosave: true

  index({title: 1}, {unique: true})

  validates :title, :file_path, presence: true
  validates :title, uniqueness: true

  def file_path
    FILE_PATH + category.to_s.pluralize + "/" + super
  end

  def add_self_to_child(post)
    post.related_posts << self unless post.related_posts.include? self
  end
end
