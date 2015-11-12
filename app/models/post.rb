class Post
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  field :title, type: String
  field :tags, type: Array
  field :file_path, type: String
  has_many :comments
end
