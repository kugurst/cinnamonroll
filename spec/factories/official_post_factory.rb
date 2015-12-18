FactoryGirl.define do
  factory :https_on_the_cheap, class: Post do |p|
    file_path 'https_on_the_cheap'
    category :thought
    title 'HTTPS on the Cheap'
    additional_info {{ subtitle: 'A short excursion into TLS, RSA, and AES', splash_img: 'send_pk_snippet.png' }}
    tags { ['security', 'forge', 'aes', 'rsa'] }
  end
end
