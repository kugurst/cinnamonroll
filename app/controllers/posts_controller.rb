class PostsController < ApplicationController
  include SessionHelper

  before_action :set_post, only: [:show, :edit, :update, :destroy, :comments]

  layout "posts/show_post", only: :show

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    # pre-sorting the comments means that when we tree them, they'll be encountered in the sorted order.
    comments = @post.comments.sort { |x,y| x.c_at <=> y.c_at }
    @comment_list = PostsHelper.tree_comments comments
    @posts = Post.where category: @post[:category]
    @category = @post[:category]
  end

  def comments
    @comment_list = PostsHelper.tree_comments @post
    render layout: false
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  def category
    path = URI.parse(request.original_url).path
    path.gsub! '/', ''

    # get all posts with this category
    @posts = Post.order_by(created_at: 'desc').where(category: path.singularize)
    @category =  path.singularize.to_sym
  end

  # POST /posts
  # POST /posts.json
  def create
    return request_aes_key if decrypt_sym!(:post).nil?
    pp = post_params
    pp[:tags] = pp[:tags].split(/,\s*/) if pp[:tags].is_a? String
    @post = Post.new(pp)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    return request_aes_key if decrypt_sym!(:post).nil?
    pp = post_params
    pp[:tags] = pp[:tags].split(/,\s*/) if pp[:tags].is_a? String

    respond_to do |format|
      if @post.update(pp)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      if params.key? :category and params.key? :file_path
        begin
          @post = Post.includes(:comments).find_by category: params[:category].to_s.singularize, file_path: params[:file_path]
        rescue Mongoid::Errors::DocumentNotFound
          @post = Post.includes(:comments).find_by title: params[:category]
          render params[:file_path]
        end
      else
        @post = Post.includes(:comments).find_by title: params[:id]
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      enc_require(:post).permit(:title, :file_path, :tags, :comments)
    end
end
