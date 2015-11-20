class CommentThread
  include Mongoid::Document

  field :user, type: String
  field :post, type: String
  field :comments, type: String

end
