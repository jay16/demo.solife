#encoding: utf-8
require "model-base"
class ActionLog
    include DataMapper::Resource
    include Utils::DataMapper::Model
    extend  Utils::DataMapper::Model

    property :id        , Serial 
    property :panel     , String   , :required => true
    property :user_id   , Integer 
    property :model_name, String 
    property :model_id  , Integer
    property :action    , String
    property :human     , String
    property :detail    , Text

    belongs_to :user, :required => false

    # instance methods
    def account?
      panel == "account"
    end
    def cpanel?
      panel == "cpanel"
    end
end

