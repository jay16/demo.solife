#encoding: utf-8
require "json"
require "rest-client"
require "timeout"
require "app/models/nxscae_model.rb"
require "app/models/nxscae_dayinfo.rb"
require "app/models/nxscae_cache.rb"
# json structure:
#
# tables: [{
#  "num": 13,                    #序号
#  "code": "601005",             #藏品代码
#  "fullname": "虎首大银章",       #藏品简称
#  "YesterBalancePrice": 77890,  #昨收盘
#  "OpenPrice": 85680,           #今开盘
#  "CurPrice": 85680,            #最新价
#  "CurrentGains": 10,           #涨跌幅
#  "TotalAmount": 1,             #成交量
#  "TotalMoney": 85680,          #成交金额
#  "HighPrice": 85680,           #最高价
#  "LowPrice": 85680             #最低价
# }],
# sumNum: 11582,                 #总成交量
# sumMoney: 32557419.42,         #总成交金额
# time: "2015-05-30 15:00:00"    #时间

module Nxscae
  class Tables
    def self.search(keywords, options={})
      nxscae = new(options)
      keywords = keywords.to_s.split(/\s+/) unless keywords.is_a?(Array)
      products = nxscae.search(keywords)

      raw_result = products.map do |product|
        (<<-HEREDOC).gsub(/^ {10}/, '')
          藏品简称: #{product['fullname']}
          最新价格: #{product['CurPrice']}
          昨日收盘: #{product['YesterBalancePrice']}
          股价涨幅: #{product['CurrentGains']}%
        HEREDOC
      end.join("\n")

      (<<-HEREDOC).gsub(/^ {8}/, '')
        关键字: #{keywords.join(",")}
        搜索到 #{products.count} 条结果
              
        #{raw_result}
        
        nxscae时间:
        #{nxscae.stock_time}
      HEREDOC
    end

    def self.read_from_local(cache_content, options={})
      nxscae = new(options)
      nxscae.read_from_local(cache_content)
    end

    attr_accessor :nxscaes
    def initialize(options={})
      @options  = options
      @nxscaes  = {}
    end

    def stock_time
      @nxscaes["time"]
    end

    def read_tables_and_cached
      simulator_browser = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.132 Safari/537.36"
      response  = RestClient.post @options[:nxscae_stock_url], { user_agent: simulator_browser, :content_type => :json }
      @nxscaes  = JSON.parse(response.body)
      NxscaeCache.create(content: response.body)
      cache_tables_when_read
    end

    def read_from_local(content)
      @nxscaes  = JSON.parse(content)
      cache_tables_when_read
    end

    def check_data_valid
      @nxscaes["time"] && @nxscaes["tables"] && @nxscaes["tables"].is_a?(Array)
    end
    def cache_tables_when_read
      unless check_data_valid
        puts "Bug"*10
      end

      time_info = { time: @nxscaes["time"] }
      @nxscaes["tables"].each do |table|
        latest_info = {
          code: table["code"],
          fullname: table["fullname"],
          high_price: table["HighPrice"],
          low_price: table["LowPrice"],
          sum_num: @nxscaes["sumNum"],
          sum_money: @nxscaes["sumMoney"],
        }

        unless nxscae_model = NxscaeModel.first(latest_info)
          nxscae_model = NxscaeModel.create(latest_info.merge(time_info))

        #   puts "create model %s" % table["fullname"]
        # else 
        #   puts "nothing model %s" % table["fullname"]
        end

        day_info = latest_info.merge({
          yester_balance_price: table["YesterBalancePrice"],
          open_price: table["OpenPrice"],
          cur_price: table["CurPrice"],
          current_gains: table["CurrentGains"],
          total_amount: table["TotalAmount"],
          total_money: table["TotalMoney"]
        })
        unless nxscae_model.nxscae_dayinfos.first(day_info)
          nxscae_model.nxscae_dayinfos.new(day_info.merge(time_info)).save
        
        #   puts "create dayinfo %s" % table["fullname"]
        # else 
        #   puts "nothing dayinfo %s" % table["fullname"]
        end
      end
    end

    def read_tables_with_timeout
      begin
        Timeout::timeout(3.5) do
          read_tables_and_cached
        end
      rescue => e
        puts e.message
      ensure
      end
    end

    def search_tables(keywords)
      if keywords.empty?
        @nxscaes["tables"]
      else
        @nxscaes["tables"].find_all do |product|
          is_what_i_want = true
          keywords.each do |keyword|
            unless product["fullname"] =~ /#{keyword}/
              is_what_i_want = false
              break
            end
          end
          is_what_i_want
        end
      end
    end

    def search(keywords=[])
      read_tables_with_timeout
      search_tables(keywords)
    end
  end
end

