class StaticController < ApplicationController
  # @posts is never empty. There's no site without posts
  def landing
    if session.has_key? :notice
      gon.push notice: session[:notice]
      session.delete :notice
    end
    @posts = Post.order_by u_at: 'desc'
  end

  def about_me
  end
end
