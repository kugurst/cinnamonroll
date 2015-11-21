require "rails_helper"

describe Comment, 'state' do
  context "considering required fields" do
    subject { create :comment }

    # Make sure that all fields that are required to be present are present
  end

  context "deleting a comment removes it from the comment list" do
    subject { create :comment, :with_sub_comments, sub_list: [1] }

    it "nullifies the reference in comment" do
      child = subject.comments[0]


      expect(child.delete).to be
      loaded_comment = Comment.find_by id: subject.id


      expect(loaded_comment.comments).to be_empty
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
    subject { create :comment, :with_sub_comments, sub_list: [sub_comments, sub_sub_comments] }

    it { is_expected.to be_has_comments }

    # it "should have children with a parent" do
    #   expect(subject.comments[0]).to be_has_parent_comment
    # end

    it "should have children with children" do
      expect(subject.comments[0]).to be_has_comments
    end

    # it "should have children with children with parents" do
    #   expect(subject.comments[0].comments[0]).to be_has_parent_comment
    # end

    modifying_string = "test"
    it "should save changes to an edited child" do
      child = subject.comments[0]
      # previous_body = child.body
      child.body += modifying_string


      expect(subject.save!).to be


      loaded_comment = Comment.find_by id: subject.id


      loaded_child = loaded_comment.comments[0]
      expect(loaded_child.id).to be == child.id
      expect(loaded_child.body).to be == child.body
    end

    it "should not destroy sub comments when destroy" do
      child_comment = subject.comments[0]


      subject.destroy


      expect(child_comment.deleted).to_not be
    end

    it 'should be able to save direct sub comment removal' do
      expect(subject.save).to be
      subject.comments.delete subject.comments[0]


      expect(subject.comments.length).to be == sub_comments - 1
      expect(subject.save).to be


      lc = Comment.find_by id: subject.id
      expect(lc.comments.length).to be == subject.comments.length
    end

    it 'should be able to save multi-nested comment removal' do
      expect(subject.save).to be
      sub_length = subject.comments[0].comments.length
      subject.comments[0].comments[0].delete


      expect(subject.save).to be


      expect(subject.comments[0].comments.length).to be == sub_length - 1


      lc = Comment.find_by id: subject.id


      expect(lc.comments[0].comments.length).to be == subject.comments[0].comments.length
    end
  end
end
