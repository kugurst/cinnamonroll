module PostsHelper
  CATEGORY_DESCRIPTIONS = {project: "cool things I've made",
                           thought: "miscellaneous topics",
                           review: "neat (or not so neat) works that I write about",
                           testing: "debugging this website"}

  SORT_DEFAULTS = { order: :ascending,
                    sort: :date }

  POST_CAT_CACHE_PATH = '/posts/category'

  class StubComment
    def temp_comments
      @temp_comments ||= []
    end
    def temp_comments=(list)
      @temp_comments = list
    end
  end

  def self.add_to_comment_list(list, com, opts = {})
    opts = SORT_DEFAULTS.merge opts

    # default behavior, insert at the end of the list
    insert_pos = list.length
    if opts[:sort] == :date
      if opts[:order] == :ascending
        list.each_with_index do |e, i|
          if com.c_at < e.c_at
            insert_pos = i
            break
          end
        end
      elsif opts[:order] == :descending
        list.each_with_index do |e, i|
          if com.c_at > e.c_at
            insert_pos = i
            break
          end
        end
      end
    end
    list.insert insert_pos, com
  end

  def self.tree_comments(post)
    PostsHelper.tree_comments_2_pass post
  end

  def self.tree_comments_2_pass(post, opts = {})
    found_comments = {}
    comment_list = []
    post.comments.each do |c|
      # add this element to the scanned list
      found_comments[c.id] = c
      # add this comment to the top-level list if it is a top level comment
      if c.nesting_level == 0
        PostsHelper.add_to_comment_list comment_list, c, opts
      end
    end
    # parent all comments
    found_comments.each do |k, v|
      # Get our parent
      if v.parent_comment_id
        parent = found_comments[v.parent_comment_id]
        # parent.temp_comments << v
        PostsHelper.add_to_comment_list parent.temp_comments, v, opts
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
    PostsHelper.banned_category cat
  end

  def self.banned_category(cat)
    cat == :testing && Rails.env == "production"
  end

  def self.load_posts(cat = nil)
    cat = :all if cat.nil?
    Rails.cache.fetch(POST_CAT_CACHE_PATH + cat.to_s)
  end
end
