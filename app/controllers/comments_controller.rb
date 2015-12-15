class CommentsController < ApplicationController
  include SessionHelper

  before_action :set_comment, only: [:show, :edit, :update, :destroy]

  # GET /comments
  # GET /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    @enc_comment = Comment.new
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.json
  def create
    # require a referer and user
    return if head_if_true(:forbidden, post_params.blank?)
    return if head_if_true :unauthorized, !logged_in?, 'you must be logged in to comment'

    return request_aes_key if decrypt_sym!(:comment).nil?
    decrypt_sym! :post

    # Get the post from the params
    pp = post_params
    post = Post.cat_and_path_to_post pp[:category], pp[:file_path]
    return if head_if_true(:forbidden, post.nil?)

    # Set the additional comment fields
    cp = comment_params
    cp[:body].strip!
    cp[:post] = post
    cp[:user] = current_user
    parent_comment_id = cp.delete :parent_comment_id
    get_all_comments = cp.delete :all
    @parent_comment = nil
    unless parent_comment_id.nil?
      results = Comment.where id: parent_comment_id
      @parent_comment = results[0] if results.exists?
    end
    @comment = Comment.new(cp)

    respond_to do |format|
      if !current_user.email_confirmed
        format.html do
          flash[:notice] = "you must confirm your email before you can comment"
          redirect_to return_point_if_none root_path
        end
        format.json do
          msg = { error: "you must confirm your email before you can comment" }
          render json: msg, status: :unauthorized
        end
      elsif @comment.valid?
        @parent_comment.comments << @comment if @parent_comment
        @comment.save
        com = ""
        if !get_all_comments
          com = render_to_string layout: false
        else
          @comment_list = PostsHelper.tree_comments post
          com = render_to_string 'post_comments', layout: false
        end

        msg = { html: com, id: @comment.id.to_s }
        format.json { render json: msg, status: :ok }
      else
        format.html do
          flash[:notice] = "Comment failed to save"
          redirect_to return_point_if_none root_path
        end
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to comments_url, notice: 'Comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def box
    @reply = true if params[:type] == :reply
    render 'box', layout: false
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      enc_require(:comment).permit(:body, :user, :created_at, :modified_at, :comments, :parent_comment_id, :all)
    end

    def post_params
      enc_fetch(:post).permit(:category, :file_path)
    end
end
