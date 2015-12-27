json.post do
  PostsHelper::POST_SOURCE_METADATA.each do |m|
    eval "json.#{m} yield :post_#{m} if content_for? :post_#{m}"
  end
end
