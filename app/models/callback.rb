#encoding: utf-8
require "model-base"
class Callback
    include DataMapper::Resource
    include Utils::DataMapper::Model
    #extend  Utils::DataMapper::Model
    include Utils::ActionLogger

    property :id        , Serial 
    property :outer_url , String  , :required => true
    property :token     , String  , :required => true
    property :keyword   , String  , :required => true
    property :desc      , Text

    belongs_to :weixiner, required: false

    # instance methods
    def human_name
      "回调函数"
    end
end
