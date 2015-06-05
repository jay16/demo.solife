#encoding: utf-8
FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "name#{n}" }
    sequence(:email) { |n| "email-#{Time.now.to_i}@solife.us" }
    password "password-#{Time.now.to_i}"
    created_at Time.now
  end

  factory :admin, :parent => :user do
    email Settings.admins.split(/;/).first
  end
end
