FactoryGirl.define do
  factory :comment do |c|
    association :user
    association :post
    body Forgery::LoremIpsum.words 20

    trait :with_sub_comments do
      transient do
        comment_list []
      end

      after(:create) do |com, evaluator|
        puts "creating"
        unless evaluator.comment_list.empty?
          create_list(:comment, evaluator.comment_list[0], :with_sub_comments, post: com.post, comment_list: evaluator.comment_list[1, evaluator.comment_list.length]).each do |e|
            com.child_comments << e
          end
        end
        # p com.comments
      end
    end
  end
end
