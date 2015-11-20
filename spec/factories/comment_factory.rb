FactoryGirl.define do
  factory :comment do |c|
    transient do
      words 20
      comment_list []
      same_user false
    end

    # association :user
    # association :post
    body { Forgery::LoremIpsum.words words }

    trait :with_sub_comments do
      after(:create) do |com, evaluator|
        # due to the workings of embedded, we have to build each comment first, rather than recursing to the end and building back up
        # shorten our lines
        cl = evaluator.comment_list
        # constant for every comment built
        new_com_hash = { words: evaluator.words }
        # starting our recursion
        to_add = [com]
        while !cl.empty?
          next_stage = []
          to_add.each do |current_comment|
            i = 0
            while i < cl[0]
              new_com = build :comment, new_com_hash
              # aggregate the children
              next_stage << (current_comment.comments.build body: new_com.body)
              i += 1
            end
          end
          # next level
          to_add = next_stage
          cl = cl[1, cl.length]
        end
      end
    end
  end
end
