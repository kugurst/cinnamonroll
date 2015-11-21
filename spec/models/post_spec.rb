require "rails_helper"

describe Post, 'state' do
  subject { create :post }

  test_path = "test"
  it "puts #{Post::FILE_PATH} before the specified path" do
    subject.file_path = test_path


    expect(subject.file_path).to be == Post::FILE_PATH + test_path
  end

  second_test_path = Post::FILE_PATH + "second_test"
  it "doesn't put #{Post::FILE_PATH} before a path that already has it" do
    subject.file_path = second_test_path

    expect(subject.file_path).to be == second_test_path
  end

  it "requires a unique title" do
    post = build :post
    post.title = subject.title


    expect(post.save).to_not be
  end
end

describe Post, '#comments' do
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
    end

    it "has the correct number of comment threads" do
      expect(@post.comment_threads.length).to be == list[0]
    end

    it "has comments that belong to itself, and only itself" do
      com_level = @post.comment_threads
      until com_level.empty?
        next_level = []
        com_level.each do |com|
          expect(com.post).to be == @post
          next_level.concat com.comments
        end
        com_level = next_level
      end
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
