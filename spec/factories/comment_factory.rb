FactoryGirl.define do
  factory :comment do |c|
    transient do
      words 20
      comment_list []
    end

    association :user
    association :post
    body { Forgery::LoremIpsum.words words }

    trait :with_sub_comments do
      after(:create) do |com, evaluator|
        unless evaluator.comment_list.empty?
          create_list(:comment, evaluator.comment_list[0], :with_sub_comments, post: com.post, words: evaluator.words, comment_list: evaluator.comment_list[1, evaluator.comment_list.length]).each do |e|
            com.child_comments << e
          end
        end
      end
    end
  end
end
