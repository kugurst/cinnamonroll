require "rails_helper"

describe Comment do
  it "makes a comment with nested comments" do
    comment = create :comment, :with_sub_comments, comment_list: [5]
    p comment
  end
end
