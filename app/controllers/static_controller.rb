class StaticController < ApplicationController
  # @posts is never empty. There's no site without posts
  def landing
    @posts = Post.order_by u_at: 'desc'
  end

  def about_me
  end
end
