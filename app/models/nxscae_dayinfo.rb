#encoding: utf-8
require "config/model-base.rb"
require "lib/utils/data_mapper/model.rb"
class NxscaeDayinfo
    include DataMapper::Resource
    include ::Utils::DataMapper::Model

    property :id, Serial 
    #藏品代码
    property :code, String
    #藏品简称
    property :fullname, String
    #最高价
    property :high_price, Float
    #最低价
    property :low_price, Float  
    #昨收盘
    property :yester_balance_price, Float  
    #今开盘
    property :open_price, Float  
    #最新价
    property :cur_price, Float  
    #涨跌幅
    property :current_gains, Float  
    #成交量
    property :total_amount, Integer  
    #成交金额
    property :total_money, Float  
    #总成交量
    property :sum_num, Integer 
    #总成交金额
    property :sum_money, Float
    #时间
    property :time, String


    belongs_to :nxscae_model, :required => false

    # instance methods
    def human_name
      "nxscae产品行情"
    end
end
