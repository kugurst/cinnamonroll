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
    return if head_if_true(:forbidden, request.referer.blank? && Rails.env != 'test')
    return if head_if_true(:unauthorized, !logged_in?)

    return request_aes_key if decrypt_sym!(:comment).nil?

    # Get the post from the URL
    referer = URI(request.referer).path
    set_return_point referer
    post = Post.path_to_post referer
    return if head_if_true(:forbidden, post.nil?)

    # Set the additional comment fields, and add the comment to its parent, if present
    cp = comment_params
    cp[:post_id] = post.id
    cp[:user_id] = current_user.id
    parent_comment_id = cp.delete :parent_comment_id
    parent_comment = nil
    unless parent_comment_id.nil?
      results = Comment.where(id: parent_comment_id)
      parent_comment = results[0] if results.exists?
    end
    @comment = Comment.new(cp)

    respond_to do |format|
      if @comment.valid?
        parent_comment.comments << @comment unless parent_comment.nil?
        current_user.comments << @comment
        post.comment_threads << @comment if @comment.nesting_level == 0
        current_user.save
        post.save
        format.html { redirect_to return_point }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html do
          flash[:notice] = "Comment failed to save"
          redirect_to return_point
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
      enc_require(:comment).permit(:body, :user, :created_at, :modified_at, :comments)
    end
end
