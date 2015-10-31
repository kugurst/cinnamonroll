json.array!(@posts) do |post|
  json.extract! post, :id, :title, :created_at, :modified_at, :tags, :comments
  json.url post_url(post, format: :json)
end
