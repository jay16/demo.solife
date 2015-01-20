#encoding: utf-8
require "model-base"
class CallbackData
    include DataMapper::Resource
    include Utils::DataMapper::Model
    #extend  Utils::DataMapper::Model
    include Utils::ActionLogger

    property :id        , Serial 
    property :params    , Text    , :required => true
    property :result    , String  , :required => true , :default => "waiting"
    property :response  , Text 

    belongs_to :callback, required: false

    # instance methods
    def human_name
      "回调数据"
    end
end
