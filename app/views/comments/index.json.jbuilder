json.array!(@comments) do |comment|
  json.extract! comment, :id, :body, :user, :created_at, :modified_at, :comments
  json.url comment_url(comment, format: :json)
end
