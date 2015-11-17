FactoryGirl.define do
  factory :post do |p|
    p.sequence(:title) { |n| Forgery::Email.subject + n.to_s }
    file_path Forgery::Name.first_name
  end
end
