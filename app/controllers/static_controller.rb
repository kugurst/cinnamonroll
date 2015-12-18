class StaticController < ApplicationController
  # @posts is never empty. There's no site without posts
  def landing
    @posts = Post.all
    @posts = @posts.sort { |a,b| -(a.u_at <=> b.u_at) }
  end

  def about_me
  end
end
