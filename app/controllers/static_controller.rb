class StaticController < ApplicationController
  # @posts is never empty. There's no site without posts
  def landing
    @posts = Post.order_by u_at: 'desc'
    @most_recent_post = @posts[0]
    puts @most_recent_post
  end

  def about_me
  end
end
