#encoding: utf-8
require "model-base"
class WeixinerInfo
    include DataMapper::Resource
    # include Utils::DataMapper::Model
    # extend  Utils::DataMapper::Model
    # include Utils::ActionLogger

    property :id       , Serial 
    property :subscribe, Boolean
    property :openid   , String
    property :nickname , String
    # 用户的性别，值为 1 时是男性，值为 2 时是女性，值为 0 时是未知
    property :sex      , Integer
    property :language , String
    property :city     , String
    property :province , String
    property :country  , String
    property :headimgurl    , Text
    property :subscribe_time, Integer
    property :unionid  , String
    property :remark   , Text

    belongs_to :weixiner, required: false

    # instance methods
    def human_name
      "微信用户信息"
    end
end
