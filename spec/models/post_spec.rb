require "rails_helper"

describe Post, 'state' do
  subject { create :post }

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

describe Post, '#comments' do
  context 'with no nested comments' do
    num_comments = 5
    before :all do
      @post = create :post, :with_comments, comment_list: [num_comments]
    end

    it "has the right number of comments" do
      expect(@post.comments.length).to be == num_comments
    end

    it "has comments that belong to itself, and only itself" do
      @post.comments.each do |c|
        expect(c.post).to be == @post
      end
    end
  end

  context 'with nested comments' do
    list = [4, 2, 3, 1]
    before :all do
      @post = create :post, :with_comments, comment_list: list
    end

    total_comments = 0
    it "has the correct number of comments" do
      i = 0
      mult = 1
      while i < list.length
        total_comments += list[i] * mult
        mult *= list[i]
        i += 1
      end

      expect(@post.comments.length).to be == total_comments
    end

    it "has comments that belong to itself, and only itself" do
      @post.comments.each do |com|
        expect(com.post).to be == @post
      end
    end

    it "sets the post when a comment is added to a chain" do
      sub_comment = @post.comments[0].comments[0]
      expect(sub_comment.post).to be == @post

      new_comment = build :comment, post: nil
      sub_comment.comments << new_comment


      expect(new_comment.save).to be


      expect(new_comment.post).to be == @post
    end

    it "removes a comment that was added" do
      comment = @post.comments[0].comments[0].comments[0]


      expect(@post.comments[0].comments[0].delete comment).to be


      expect(@post.save).to be
    end

    it "updates the comment count when a nested comment is added" do
      sub_comment = @post.comments[0].comments[0]
      new_comment = build :comment, post: nil
      sub_comment.comments << new_comment


      expect(new_comment.save).to be
      loaded_post = Post.find_by id: @post.id


      expect(@post.comments.length).to be == total_comments + 1
      expect(loaded_post.comments.length).to be == total_comments + 1
    end

    it 'removes a direct comment' do
      length = @post.comments.length


      @post.comments.delete @post.comments[@post.comments.length - 1]


      expect(@post.update_attribute :comments, @post.comments).to be
      expect(@post.comments.length).to be == length - 1


      loaded_post = Post.find_by id: @post.id
      expect(loaded_post.comments.length).to be == @post.comments.length
    end

    it "deletes the comments when the post is destroyed" do
      comment = @post.comments[0].comments[0]


      @post.destroy


      expect(Comment.where(id: comment.id).exists?).to_not be
    end
  end
end
