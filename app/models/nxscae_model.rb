#encoding: utf-8
require "model-base"
class NxscaeModel
    include DataMapper::Resource
    include Utils::DataMapper::Model

    property :id, Serial 
    #藏品代码
    property :code, String , :required => true, :unique => true 
    #藏品简称
    property :fullname, String
    #最高价
    property :high_price, Float
    #最低价
    property :low_price, Float 
    #总成交量
    property :sum_num, Integer 
    #总成交金额
    property :sum_money, Float
    #时间
    property :time, String

    has n, :nxscae_dayinfos

    def latest_info
      self.nxscae_dayinfos.first(time: time)
    end
    
    # instance methods
    def human_name
      "nxscae产品"
    end
end
