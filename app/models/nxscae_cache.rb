#encoding: utf-8
require "model-base"
class NxscaeCache
    include DataMapper::Resource
    include Utils::DataMapper::Model

    property :id, Serial 
    property :content, Text

    # instance methods
    def human_name
      "nxscae缓存"
    end
end
