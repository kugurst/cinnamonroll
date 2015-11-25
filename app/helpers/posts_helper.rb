module PostsHelper
  def self.tree_comments(post)
    found_comments = {}
    comment_list = []
    post.comments.each do |c|
      # add this element to the scanned list
      found_comments[c.id] = c
      comment_list << c if c.nesting_level == 0
    end
    # parent all comments
    found_comments.each do |k, v|
      # Get our parent
      if v.parent_comment_id
        parent = found_comments[v.parent_comment_id]
        parent.temp_comments << v
      end
    end
    comment_list
  end
end
