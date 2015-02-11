#encoding: utf-8
require "model-base"
class ChangeLog
    include DataMapper::Resource
    include Utils::DataMapper::Model
    #extend  Utils::DataMapper::Model
    include Utils::ActionLogger

    property :id        , Serial 
    property :title     , String
    property :content   , Text
    property :source    , String, :default => "web"
    property :author    , String
    property :editor    , String
    property :tag       , String 
    property :duration  , String 
    property :remark    , String
    property :publish   , Boolean, :default => false

    # instance methods
    def human_name
      "更新日志"
    end
end
