#encoding: utf-8
require "model-base"
class Message # 微信消息
    include DataMapper::Resource
    include Utils::DataMapper::Model
    extend  Utils::DataMapper::Model

    property :id             , Serial 
    property :msg_type       , String  , :required => true
    property :raw_message    , Text    , :required => true
    property :to_user_name   , String  , :required => true
    property :from_user_name , String  , :required => true
    # debug it without below two
    property :create_time    , String#  , :required => true
    property :msg_id         , String#  , :required => true
    # text
    property :content        , Text
    # image
    property :pic_url        , Text
    # location
    property :location_x     , String
    property :location_y     , String
    property :scale          , String
    property :label          , String
    # link
    property :title          , String
    property :description    , Text
    property :url            , Text
    # event
    property :event          , String
    property :latitude       , String
    property :precision      , String

    # 响应内容 - 自定义
    property :response       , Text

    belongs_to :weixiner, :required => false

    def reply
      messages = self.weixiner.messages
      message_count = messages.count
      today_s_count = messages.all(:created_on => Time.now).count
      text = "第%d条消息\n" % message_count + 
        "今天第%d条消息" % today_s_count
      update(response: text)
      self.response
    end

    # instance methods
    def human_name
      "微信消息"
    end
end
