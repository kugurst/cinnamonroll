class Post
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  FILE_PATH = "posts/sources/"

  field :title, type: String
  field :tags, type: Array, default: []
  field :file_path, type: String
  has_many :comments, autosave: true, dependent: :delete

  validates :title, :file_path, presence: true
  validates :title, uniqueness: true

  def file_path=(path)
    path = FILE_PATH + path unless path.start_with? FILE_PATH
    super path
  end
end
