#encoding: utf-8
FactoryGirl.define do
  factory :user do
    sequence(:name)  {|n| "name#{n}" }
    sequence(:email) {|n| "email#{n}@solife.us" }
    password 'password'
    password_confirmation 'password'
    created_at Time.now
  end

  factory :admin, :parent => :user do
    email Settings.admins.split(/;/).first
  end
end
