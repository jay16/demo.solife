#encoding: utf-8
require "json"
require "rest-client"

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

    attr_accessor :nxscaes, :is_cache
    def initialize(options={})
      @options  = options
      @nxscaes  = {}
      @is_cache = false
    end

    def stock_time
      @nxscaes["time"]
    end

    def cache_files_path(timestamp)
      "%s/tmp/nxscae-tables.%s.json" % [@options[:app_root], timestamp]
    end
    
    def clear_cache_files
      `rm #{@options[:app_root]}/tmp/nxscae-tables.*.json`
    end

    def read_tables_and_cached
      simulator_browser = ""
      response  = RestClient.post @options[:nxscae_stock_url], { user_agent: simulator_browser, :content_type => :json }
      @nxscaes  = JSON.parse(response.body)
      cache_tables_when_read
    end

    def read_tables_when_cached
      today = Time.now
      hour  = today.strftime("%H").to_i
      # 每天下午15时更新盘信息
      if hour < 15
        today = today - 60*60*24
      end

      timestamp = today.strftime("%Y%m%d150000")
      cachepath = cache_files_path(timestamp)
      if File.exist?(cachepath)
        @nxscaes  = JSON.parse(IO.read(cachepath))
        @is_cache = true
      else
        read_tables_and_cached
        @is_cache = false
      end
    end

    def cache_tables_when_read
      timestamp = @nxscaes["time"].gsub(/\s|:|-/, "")
      cachepath = cache_files_path(timestamp)
      File.open(cachepath, "w:UTF-8") { |file| file.puts(@nxscaes.to_json) }
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
      read_tables_when_cached
      search_tables(keywords)
    end
  end
end

