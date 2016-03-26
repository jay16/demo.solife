#encoding: utf-8
require "model-base"
class Message # 微信消息
    include DataMapper::Resource
    # include Utils::DataMapper::Model
    # extend  Utils::DataMapper::Model

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
    property :recognition    , Text , :default => ""
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
      text = <<-`TEXT`
        echo 第#{message_count}条消息
        echo 今天第#{today_s_count}条消息
      TEXT
      text.force_encoding("UTF-8")
    end

    def recognition_with_punctuation
      _recognition = self.recognition.dup.force_encoding('UTF-8').strip || ""
      { "逗号"   => ",",
        "句号"   => "。",
        "空格"   => " ",
        "左括号" => "(",
        "右括号" => ")",
        "感叹号" => "!",
        "分号"   => ";",
        "问号"   => "?",
        "波浪符" => "~",
        "连字号" => "-",
        "破折号" => "--",
        "下划线" => "_",
        "冒号"   => ":",
        "省略号" => "...",
        "单引号" => "'",
        "又引号" => '"',
        "左花括号" => "{",
        "右花括号" => "}",
        "左圆括号" => "(",
        "右圆括号" => ")"
      }.each do |key, value|
        _recognition.gsub!(key, value) if _recognition =~ /#{key}/
      end
      return _recognition
    end

    # instance methods
    def human_name
      "微信消息"
    end
end
