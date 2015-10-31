class Post
  include Mongoid::Document
  field :title, type: String
  field :created_at, type: String
  field :modified_at, type: String
  field :tags, type: String
  field :comments, type: String
end
