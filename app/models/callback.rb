#encoding: utf-8
require "model-base"
class Callback
    include DataMapper::Resource
    include Utils::DataMapper::Model
    #extend  Utils::DataMapper::Model
    include Utils::ActionLogger

    property :id        , Serial 
    property :email     , String  , :required => true, :unique => true
    property :name      , String
    property :password  , String  , :required => true
    property :gender    , Boolean 
    property :country   , String  
    property :province  , String  
    property :city      , String  

    belongs_to :weixiner, required: false

    # instance methods
    def human_name
      "回调函数"
    end
end
