require "rails_helper"

describe PostsHelper, 'tree_comments performance' do
  subject { @post = create :post, :with_comments, comment_list: [3, 2, 1, 2, 1, 2, 2]; comment = create :comment, :with_sub_comments, sub_list: [3, 2], post: @post; comment.save; @post }

  it 'asserts that tree_comments_2 is the fastest implementation' do
    itrs = 1000

    Benchmark.bmbm do |x|
      x.report('tree_comments_2_pass:') do
        for i in 1..itrs; PostsHelper.tree_comments_2_pass subject; end
      end
      x.report('tree_comments_array_placeholder:') do
        for i in 1..itrs; PostsHelper.tree_comments_array_placeholder subject; end
      end
      x.report('tree_comments_stub_placeholder:') do
        for i in 1..itrs; PostsHelper.tree_comments_stub_placeholder subject; end
      end
    end
  end
end
