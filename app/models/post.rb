class Post
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  FILE_PATH = "posts/sources/"
  CATEGORIES = [:review, :project, :thought, :testing]

  def self.path_to_post(path)
    path_arr = path.split('/').delete_if {|p| p.blank?}
    post = nil
    if path_arr.length == 3
      if path_arr[0] == 'posts'
        # We can now try the path
        results = Post.where(category: path_arr[1].singularize, file_path: path_arr[2])
        post = results[0] if results.exists?
      end
    end
    post
  end

  field :title, type: String
  field :tags, type: Array, default: []
  field :file_path, type: String
  field :category, type: Symbol, default: :testing
  has_many :comments, dependent: :delete, autosave: true
  has_and_belongs_to_many :related_posts, class_name: "Post", autosave: true, after_add: :add_self_to_child

  validates :title, :file_path, presence: true
  validates :title, uniqueness: true

  index title: 1

  def file_path
    FILE_PATH + category + "/" + super
  end

  def category
    self[:category].to_s.pluralize
  end

  def to_param
    title
  end

  def add_self_to_child(post)
    post.related_posts << self unless post.related_posts.include? self
  end
end
