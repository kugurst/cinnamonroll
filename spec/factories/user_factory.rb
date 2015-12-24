FactoryGirl.define do
  factory :user do |u|
    u.sequence(:name) { |n| "user_#{n}" }
    u.sequence(:email) { |n| "user#{n}@cinnamonroll.com" }
    password { Forgery(:basic).password }
  end
end
