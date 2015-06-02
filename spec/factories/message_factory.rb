#encoding: utf-8
FactoryGirl.define do
  factory :message do
    sequence(:to_user_name)   {|n| "to_user_name#{n}" }
    sequence(:from_user_name) {|n| "from_user_name#{n}" }
    msg_type "text"
    raw_message "raw-message"
  end
end
