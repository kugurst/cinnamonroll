FactoryGirl.define do
  factory :comment do |c|
    transient do
      words 20
      sub_list []
      same_user false
    end

    post_id { create(:post).id }
    user_id { create(:user).id }
    # association :user
    # association :post
    body { Forgery::LoremIpsum.words words }

    trait :with_sub_comments do
      after(:create) do |com, eval|
        # due to the workings of embedded, we have to build each comment first,
        #   rather than recursing to the end and building back up

        # shorten our lines
        cl = eval.sub_list
        # constant for every comment built
        new_com_hash = { words: eval.words, post_id: com.post_id,
                         user_id: (com.user_id if eval.same_user)
                         }.delete_if{ |k, v| v.nil? }
        # starting our recurrence
        to_add = [com]
        while !cl.empty?
          next_stage = []
          to_add.each do |cur_com|
            i = 0
            while i < cl[0]
              new_com = build :comment, new_com_hash
              # aggregate the children
              next_stage << (cur_com.comments.build body: new_com.body,
                             user: new_com.user, post: new_com.post)
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
