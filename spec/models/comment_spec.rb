require "rails_helper"

describe Comment, 'state' do
  context "considering required fields" do
    subject { build :comment }

    # Make sure that all fields that are required to be present are present
    it { is_expected.to be_has_user }
    it { is_expected.to be_has_post }
  end

  context "deleting a comment removes it from the comment list" do
    before :all do
      @comment = create :comment, :with_sub_comments, comment_list: [1]
    end

    it "nullifies the reference in comment" do
      child = @comment.child_comments[0]


      expect(child.delete).to be
      loaded_comment = Comment.find_by id: @comment.id


      expect(loaded_comment.child_comments).to be_empty
    end
  end
end

describe Comment, '#body' do
  subject { create :comment }

  modifying_string = "test"

  it "saves changes to the body" do
    subject.body += modifying_string


    expect(subject.save!).to be


    loaded_comment = Comment.find_by id: subject.id

    expect(loaded_comment.id).to be == subject.id
    expect(loaded_comment.body).to be == subject.body
  end
end

describe Comment, 'relations' do
  context "considering embedded comments" do
    sub_comments = 2
    sub_sub_comments = 3
    subject { create :comment, :with_sub_comments, comment_list: [sub_comments, sub_sub_comments] }

    it { is_expected.to be_has_child_comments }

    it "should have children with a parent" do
      expect(subject.child_comments[0]).to be_has_parent_comment
    end

    it "should have children with children" do
      expect(subject.child_comments[0]).to be_has_child_comments
    end

    it "should have children with children with parents" do
      expect(subject.child_comments[0].child_comments[0]).to be_has_parent_comment
    end

    modifying_string = "test"
    it "should save changes to an edited child" do
      child = subject.child_comments[0]
      # previous_body = child.body
      child.body += modifying_string


      expect(subject.save!).to be


      loaded_comment = Comment.find_by id: subject.id

      loaded_child = loaded_comment.child_comments[0]
      expect(loaded_child.id).to be == child.id
      expect(loaded_child.body).to be == child.body
    end

    it "should not destroy sub comments when destroy" do
      child_comment = subject.child_comments[0]


      subject.destroy

      expect(child_comment.deleted).to_not be
    end

    it "should keep the post and user when deleted" do
      post = subject.post
      user = subject.get_user


      subject.destroy


      expect(Post.where(id: post.id).exists?).to be
      expect(User.where(id: user.id).exists?).to be
    end
  end
end
