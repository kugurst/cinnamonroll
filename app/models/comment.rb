class Comment
  include Mongoid::Document
  field :body, type: String
  field :user, type: String
  field :created_at, type: String
  field :modified_at, type: String
  field :comments, type: String
end
