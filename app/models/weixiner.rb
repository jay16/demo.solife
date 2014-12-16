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

    has n, :messages # 微信消息

    # instance methods
    def human_name
      "微信用户"
    end
end
