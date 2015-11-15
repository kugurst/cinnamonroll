class Post
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  def self.FILE_PATH
    "posts/sources/"
  end

  field :title, type: String
  field :tags, type: Array
  field :file_path, type: String
  has_many :comments, autosave: true

  validates :title, :file_path, presence: true
  validates :title, uniqueness: true
end
