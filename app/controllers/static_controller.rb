class StaticController < ApplicationController
  # @posts is never empty. There's no site without posts
  def landing
    @posts = Post.order_by(created_at: 'desc').limit 10
  end

  def about_me
  end
end
