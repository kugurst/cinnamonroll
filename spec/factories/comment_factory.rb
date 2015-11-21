FactoryGirl.define do
  factory :comment do |c|
    transient do
      words 20
      sub_list []
      same_user false
    end

    association :user
    association :post
    body { Forgery::LoremIpsum.words words }

    trait :with_sub_comments do
      after(:create) do |com, eval|
        unless eval.sub_list.empty?
          sl = eval.sub_list
          cl_hash = { post: com.post, words: eval.words,
                      sub_list: sl[1, sl.length],
                      user: (com.user if eval.same_user) }.delete_if{ |k, v| v.nil? }
          create_list(:comment, sl[0], :with_sub_comments, cl_hash).each do |e|
            com.comments << e
          end
        end
      end
    end
  end
end
