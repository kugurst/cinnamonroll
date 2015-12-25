class DirectoryWorker
  include Sidekiq::Worker
  sidekiq_options queue: :file_system

  def perform(dir = nil)
    dir = Rails.root.join PostsHelper::POST_SOURCE_PATH if dir.nil?
    Dir[dir + "**/*"].each do |f|
      # for each file that we think is a post
      if PostsHelper::POST_SOURCE_FILE_EXTS.include? File.extname f
        # check to see if we have it
        category, path = PostsHelper.path_to_cat_and_file_path f
        post = Post.where category: category, file_path: path
        # if it doesn't exist, let's make it
        unless post.exists?
          PostsHelper.create_post_by_path f
        # if it does, let's update its modification time
        else
          PostsHelper.update_post_by_path f
        end
      end
    end
  end
end
