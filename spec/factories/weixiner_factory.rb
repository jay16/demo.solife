#encoding: utf-8
FactoryGirl.define do
  factory :weixiner do
    sequence(:name) {|n| "weixin-name#{n}" }
    sequence(:uid)  {|n| "uid-#{Time.now.to_i}#{n}" }
    status 'subscribe'
  end
end
