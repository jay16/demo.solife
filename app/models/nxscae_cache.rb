#encoding: utf-8
require "config/model-base.rb"
require "lib/utils/data_mapper/model.rb"
class NxscaeCache
    include DataMapper::Resource
    include ::Utils::DataMapper::Model

    property :id, Serial 
    property :content, Text

    # instance methods
    def human_name
      "nxscae缓存"
    end
end
