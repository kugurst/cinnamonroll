require "rails_helper"

describe Post, 'state' do
  subject { create :post, category: :testing }

  test_path = "test"
  it "puts #{Post::FILE_PATH}/testings before the specified path" do
    subject.file_path = test_path


    expect(subject.file_path).to be == Post::FILE_PATH + "testings/" + test_path
  end

  it "changes the file_path if the category changes" do
    subject.file_path = test_path
    subject.category = :review

    expect(subject.file_path).to be == Post::FILE_PATH + "reviews/" + test_path
  end

  it "requires a unique title" do
    post = build :post
    post.title = subject.title


    expect(post.save).to_not be
  end
end

describe Post, '#related_posts' do
  it 'has a reference to all other related posts' do
    p1 = create :post
    p2 = create :post


    p1.related_posts << p2
    expect(p1.save).to be
    expect(p2).to_not be_changed


    expect(p1.related_posts).to be_include p2
    expect(p2.related_posts).to be_include p1
  end
end

describe Post, '#comment_threads' do
  context 'with no nested comments' do
    num_comments = 5
    before :all do
      @post = create :post, :with_comments, comment_list: [num_comments]
    end

    it "has the right number of comments" do
      expect(@post.comment_threads.length).to be == num_comments
    end

    it "has comments that belong to itself, and only itself" do
      @post.comment_threads.each do |c|
        expect(c.post).to be == @post
      end
    end
  end

  context 'with nested comments' do
    list = [4, 2, 3, 1]
    before :all do
      @post = create :post, :with_comments, comment_list: list
      # @post.comment_threads.each { |e| expect(e.save) }
    end

    it "has the correct number of comment threads" do
      expect(@post.comment_threads.length).to be == list[0]
    end

    it "has comments that belong to itself, and only itself" do
      com_level = @post.comment_threads
      total = 0
      until com_level.empty?
        next_level = []
        com_level.each do |com|
          total += 1
          expect(com.post).to be == @post
          next_level.concat com.comments
        end
        com_level = next_level
      end
      post_total = 0
      @post.comment_threads.each { |e| post_total += e.total_comments }

      expect(total).to be == post_total
    end

    it "persists multi-level comment_threads" do
      expect(@post.save).to be
      lp = Post.includes(:comment_threads).find_by id: @post.id

      com_level = lp.comment_threads
      total = 0
      until com_level.empty?
        next_level = []
        com_level.each do |com|
          total += 1
          expect(com.post).to be == @post
          next_level.concat com.comments
        end
        com_level = next_level
      end
      post_total = 0
      @post.comment_threads.each { |e| post_total += e.total_comments }

      expect(total).to be == post_total
    end

    it "sets the post when a comment is added to a chain" do
      sub_comment = @post.comment_threads[0].comments[0]
      expect(sub_comment.post).to be == @post

      new_comment = build :comment
      sub_comment.comments << new_comment


      expect(new_comment.save).to be


      expect(new_comment.post).to be == @post
    end

    # it "removes a comment that was added" do
    #   expect(@post.comment_threads[0].comments[0].comments[0].delete).to be
    #
    #
    #   expect(@post.save).to be
    #   expect(@post.comment_threads[0].save).to be
    #   expect(@post.comment_threads[0]).to_not be_changed
    # end

    it "updates the thread count when a comment is added" do
      thread_count = @post.comment_threads.length
      new_comment = build :comment
      @post.comment_threads << new_comment


      expect(new_comment.save).to be
      loaded_post = Post.find_by id: @post.id


      expect(@post.comment_threads.length).to be == thread_count + 1
      expect(loaded_post.comment_threads.length).to be == thread_count + 1
    end

    it 'removes a direct comment' do
      length = @post.comment_threads.length


      @post.comment_threads.delete @post.comment_threads[@post.comment_threads.length - 1]


      expect(@post.save).to be
      expect(@post.comment_threads.length).to be == length - 1


      loaded_post = Post.find_by id: @post.id
      expect(loaded_post.comment_threads.length).to be == @post.comment_threads.length
    end

    it "deletes the comments when the post is destroyed" do
      comment = @post.comment_threads[0].comments[0]


      @post.destroy


      expect(Comment.where(id: comment.id).exists?).to_not be
    end
  end
end
