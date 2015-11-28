FactoryGirl.define do
  factory :post do |p|
    transient do
      words 20
      comment_list [1]
      same_user false
    end

    p.sequence(:title) { |n| Forgery::Email.subject + n.to_s }
    additional_info {{ splash_img: Forgery::Basic.text }}
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

  factory :oh_my_zsh, class: Post do |p|
    file_path 'oh_my_zsh'
    category :testing
    title 'Oh My Zsh'
    additional_info {{ subtitle: 'A great, zero-effort way to improve the Z shell', splash_img: 'oh_my_zsh_terminal.png' }}
    tags { ['scripting', 'shell', 'enhancement'] }

    after :create do |post, eval|
      (0..1).each do
        com = create :comment, post: post
        com.save
      end
      (0..1).each do
        com = create :comment, :with_sub_comments, sub_list: [3,2], post: post
        com.save
      end
      (0..1).each do
        com = create :comment, :with_sub_comments, sub_list: [2,2,1,2,1,1], post: post
        com.save
      end
    end
  end
end
