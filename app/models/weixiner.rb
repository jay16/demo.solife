#encoding: utf-8
require "model-base"
class Weixiner
    include DataMapper::Resource
    include Utils::DataMapper::Model
    extend  Utils::DataMapper::Model
    include Utils::ActionLogger

    property :id  , Serial 
    # 微信名称
    property :uid,    String, :required => true, :unique => true
    property :status, String, :default => "subscribe"

    belongs_to :user, required: false
    has n, :messages # 微信消息
    has n, :callbacks# 回调函数 
    has 1, :weixiner_info

    def head_img_url
      default_headimgurl = "/images/headimgurl.jpeg"
      headimgurl = self.weixiner_info ? self.weixiner_info.headimgurl.strip : default_headimgurl
      headimgurl.empty? ? default_headimgurl : headimgurl
    end

    def nick_name
      self.weixiner_info ? self.weixiner_info.nickname : "TODO"
    end

    # instance methods
    def human_name
      "微信用户"
    end
end
