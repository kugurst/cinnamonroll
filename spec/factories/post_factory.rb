FactoryGirl.define do
  factory :post do |p|
    transient do
      words 20
      comment_list [1]
      same_user false
    end

    p.sequence(:title) { |n| Forgery::Email.subject + n.to_s }
    file_path Forgery::Name.first_name

    trait :with_comments do
      after(:create) do |post, eval|
        cc_args = eval.comment_list.length == 1 ? [] : [:with_sub_comments, { post: post, same_user: eval.same_user, words: eval.words, sub_list: eval.comment_list[1, eval.comment_list.length] } ]
        i = 0
        while i < eval.comment_list[0]
          post.comments << create(:comment, *cc_args)
          i += 1
        end
      end
    end
  end
end
