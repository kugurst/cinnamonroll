FactoryGirl.define do
  factory :comment do |c|
    association :user
    association :post
    body Forgery(:lorem_ipsum).words 140

    trait :with_sub_comments do
      ignore do

      end

      after :create do |com
    end
  end
end
