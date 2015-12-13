module PostsHelper
  CATEGORY_DESCRIPTIONS = {project: "cool things I've made",
                           thought: "an assortment of things that have crossed my mind",
                           review: "neat (or not so neat) things that I wrote about",
                           testing: "debugging this website"}

  class StubComment
    def temp_comments
      @temp_comments ||= []
    end
    def temp_comments=(list)
      @temp_comments = list
    end
  end

  def self.tree_comments(post)
    PostsHelper.tree_comments_2_pass post
  end

  def self.tree_comments_2_pass(post)
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
    # puts "found_comments.length: #{found_comments.length}"
    comment_list
  end

  def self.tree_comments_array_placeholder(post)
    found_comments = {}
    comment_list = []
    post.comments.each do |c|
      # parent this element
      unless c.parent_comment_id.nil?
        parent = found_comments[c.parent_comment_id]
        if parent.is_a? Array
          parent << c
        # If it's a comment, then add it to the list directly
        elsif parent.is_a? Comment
          parent.temp_comments << c
        # nil: first time this parent has been encountered
        else
          list = [c]
          found_comments[c.parent_comment_id] = list
        end
      end

      # add this comment to the list
      if found_comments.key? c.id
        # if we already exist in this list, then it's in array form
        c.temp_comments = found_comments[c.id]
      else
        found_comments[c.id] = c
      end
      comment_list << c if c.nesting_level == 0
    end
    # puts "found_comments.length: #{found_comments.length}"
    comment_list
  end

  def self.tree_comments_stub_placeholder(post)
    found_comments = {}
    comment_list = []
    post.comments.each do |c|
      # parent this element
      unless c.parent_comment_id.nil?
        parent = found_comments[c.parent_comment_id]
        if parent.nil?
          # stub the parent
          parent = StubComment.new
          found_comments[c.parent_comment_id] = parent
        end
        parent.temp_comments << c
      end

      # add this comment to the list
      if found_comments.key? c.id
        # if we already exist in this list, then it's a stub
        stub = found_comments[c.id]
        c.temp_comments = stub.temp_comments
      else
        found_comments[c.id] = c
      end
      comment_list << c if c.nesting_level == 0
    end
    # puts "found_comments.length: #{found_comments.length}"
    comment_list
  end

  def get_description(category)
    CATEGORY_DESCRIPTIONS[category.to_sym]
  end

  def post_cat_path_fallback(post)
    "/posts/#{post.category}/#{post[:file_path]}"
  end

  def banned_category(cat)
    cat == :testing && Rails.env == "production"
  end
end
