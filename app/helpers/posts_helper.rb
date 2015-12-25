require 'render_anywhere'

module PostsHelper
  CATEGORY_DESCRIPTIONS = {project: "cool things I've made",
                           thought: "miscellaneous topics",
                           review: "neat (or not so neat) works that I write about",
                           testing: "debugging this website"}

  SORT_DEFAULTS = { order: :ascending,
                    sort: :date }

  POST_CAT_CACHE_PATH = 'posts/category'
  POST_SOURCE_PATH = Rails.root.join "app", "views", Post::FILE_PATH
  POST_SOURCE_FILE_EXTS = ['.haml']
  POST_SOURCE_METADATA = ['title', 'subtitle', 'splash_img', 'splash_img_credit', 'tags']
  POST_TAG_DELIMITER = "\u0001"

  listener = Listen.to(Rails.root.join(PostsHelper::POST_SOURCE_PATH)) do |modified, added, removed|
    PostsHelper.dir_watcher modified, added, removed
  end
  listener.start

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

  def self.tree_comments_2_pass(post_or_comments, opts = {})
    found_comments = {}
    comment_list = []
    # support treeing comments from either a post or a comment list
    comments = post_or_comments
    comments = comments.comments if post_or_comments.is_a? Post

    comments.each do |c|
      # add this element to the scanned list
      found_comments[c.id] = c
      # add this comment to the top-level list if it is a top level comment
      if c.nesting_level == 0
        comment_list << c
        # PostsHelper.add_to_comment_list comment_list, c, opts
      end
    end
    # parent all comments
    found_comments.each do |k, v|
      # Get our parent
      if v.parent_comment_id
        parent = found_comments[v.parent_comment_id]
        parent.temp_comments << v
        # PostsHelper.add_to_comment_list parent.temp_comments, v, opts
      end
    end
    # puts "found_comments.length: #{found_comments.length}"
    comment_list
  end

  def self.tree_comments_array_placeholder(post_or_comments)
    found_comments = {}
    comment_list = []
    # support treeing comments from either a post or a comment list
    comments = post_or_comments
    comments = comments.comments if post_or_comments.is_a? Post

    comments.each do |c|
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

  def self.tree_comments_stub_placeholder(post_or_comments)
    found_comments = {}
    comment_list = []
    # support treeing comments from either a post or a comment list
    comments = post_or_comments
    comments = comments.comments if post_or_comments.is_a? Post

    comments.each do |c|
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

  ##
  # Given a file system path (absolute or relative) to a post, returns the category of the post as well as the file_path in the format the Post model expects
  def self.path_to_cat_and_file_path(path, real_path = false)
    category = nil
    file = nil
    # which costs more, string construction or an if statement?
    path = path.to_s unless path.is_a? String

    # get the path to the post source folder
    root = PostsHelper::POST_SOURCE_PATH.to_s
    # inspect the partition of this path
    phead, _, ptail = path.partition root
    # If the head is non-empty, then let's assume we were given a relative path and try again
    begin
      return PostsHelper.path_to_cat_and_file_path PostsHelper::POST_SOURCE_PATH.join(path).realpath, true if !phead.empty? && !real_path
    rescue Errno::ENOENT
      # the file doesn't exist anyway, so don't bother parsing
      return [nil, nil]
    end

    # if we're still here then, let's try parsing the category and path from the tail
    category, file = ptail.split '/', 2
    # convert the category to a symbol
    category = category.try :singularize
    category = category.try :to_sym
    # attempt the strip the file of its leading underscore (posts are partials) and extensions
    actual_file_index = file.try :index, /\/?[^\/]*$/ # /(^_|[^\/]*\/(_))/
    unless actual_file_index.nil? || file.nil?
      # find the leading underscore and remove it
      u_index = file.index '_', actual_file_index
      file.slice! u_index
      # to support hidden files (we don't need to, but we can at no cost), we'll look for the extension after the first character of the actual file name, which is two off from actual_file_index, since it points to the '/' directory separator
      ext_index = file.index '.', actual_file_index + 2
      file.slice! ext_index, file.length
    end

    [category, file]
  end

  def self.bundle_tags(tags)
    tags.join POST_TAG_DELIMITER
  end

  def self.unbundle_tags(tags)
    tags.split POST_TAG_DELIMITER
  end

  def self.dir_watcher(modified, added, removed)
    [modified, added, removed].each_with_index do |files, index|
      # Rather than writing the code to loop through these arrays three times, we'll loop through them generically and use
      modding = files.equal? modified
      adding = files.equal? added
      removing = files.equal? removed

      files.each do |file|
        # skip hidden files and emacs garbage
        leading_char = File.basename(file)[0]
        next if leading_char == '.' || leading_char == '#'

        # Delegate the actions
        PostsHelper.update_post_by_path file if modding
        PostsHelper.create_post_by_path file if adding
        PostsHelper.delete_post_by_path file if removing
      end
    end
  end

  def self.get_post_info_from_path(path)
    category, file_path = PostsHelper.path_to_cat_and_file_path path
    # get the post info
    pr = PostRenderer.new
    jb = pr.render file: path, layout: 'posts/get_post_content_json'
    post_json = JSON.parse jb
    post_fields = post_json['post']
    # fix the tags
    post_fields['tags'] = self.unbundle_tags post_fields['tags']

    # construct the post hash for creating the object
    post_obj_hash = { title: post_fields.delete('title'),
                      tags: post_fields.delete('tags'),
                      file_path: file_path,
                      category: category }
    # anything left in post_fields is additional_info
    additional_info = post_fields.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

    [post_obj_hash, additional_info]
  end

  def self.update_post_by_path(path, logger = Rails.logger)
    logger.info "updating: #{path}"
    # Retrieve the post
    category, file_path = PostsHelper.path_to_cat_and_file_path path
    post = Post.where category: category, file_path: file_path
    # Guarding against modified files that haven't been created yet
    return unless post.exists?
    post = post.first

    # Update the time if necessary
    time = File.mtime post.abs_file_path
    post.set u_at: time if post.u_at != time

    # Update the other post info if necessary

    # get the post info
    post_obj_hash, additional_info = get_post_info_from_path path
    # update those that need to be updated
    post_obj_hash.each do |k, v|
      eval %Q(
        post.set #{k}: v if post.#{k} != v
      )
    end
    # update the additional_info
    post.set additional_info: post.additional_info.merge(additional_info) if post.additional_info != additional_info
  end

  def self.create_post_by_path(path, logger = Rails.logger)
    logger.info "creating: #{path}"
    # get the post info
    post_obj_hash, additional_info = get_post_info_from_path path

    post = Post.new post_obj_hash
    # anything left in post_fields is additional_info
    post.additional_info = additional_info
    # update the u_at time
    time = File.mtime post.abs_file_path
    post.u_at = time
    # create the post
    logger.info "Inserting: #{post.title}"
    post.save!
  end

  def self.delete_post_by_path(path, logger = Rails.logger)
    logger.info "deleting: #{path}"
    # Retrieve the post
    category, path = PostsHelper.path_to_cat_and_file_path path
    post = Post.where category: category, file_path: path
    # Guarding against modified files that haven't been created yet
    return unless post.exists?
    post = post.first

    post.destroy
  end

  # load all posts that we may not have in database
  DirectoryWorker.perform_async
end
