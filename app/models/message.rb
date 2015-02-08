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
    # voice
    property :media_id       , Text
    property :format         , String
    property :recognition    , Text
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
    property :event_key      , String
    property :latitude       , String
    property :precision      , String

    # 响应内容 - 自定义
    property :response       , Text

    belongs_to :weixiner, :required => false

    def msg_type_human_name
      { "text"     => "文本",
        "news"     => "新闻",
        "music"    => "音乐",
        "image"    => "图片",
        "link"     => "链接",
        "video"    => "视频",
        "voice"    => "语音",
        "location" => "位置",
        "event"    => "事件"
      }.fetch(self.msg_type, "未知")
    end
    def reply
      messages = self.weixiner.messages
      message_count = messages.count
      today_s_count = messages.all(:created_on => Time.now).count
      text = ""
      text << "\n第%d条消息" % message_count
      text << "\n今天第%d条消息" % today_s_count
    end

    # instance methods
    def human_name
      "微信消息"
    end
end
