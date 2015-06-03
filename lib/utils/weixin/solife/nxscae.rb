#encoding: utf-8
require "json"
require "rest-client"
require "timeout"

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

    def cache_file_path
      "%s/tmp/nxscae-tables.json" % @options[:app_root]
    end
    
    def clear_cache_file
      `rm #{@options[:app_root]}/tmp/nxscae-tables.json`
    end

    def read_tables_and_cached
      simulator_browser = ""
      response  = RestClient.post @options[:nxscae_stock_url], { user_agent: simulator_browser, :content_type => :json }
      @nxscaes  = JSON.parse(response.body)
      cache_tables_when_read
    end

    def read_tables_with_timeout
      begin
        Timeout::timeout(3.5) do
          read_tables_and_cached
          @is_cache = false
        end
      rescue => e
        @nxscaes  = JSON.parse(IO.read(cache_file_path))
        @is_cache = true
        puts e.message
      ensure
        puts "read cache?: #{@is_cache}"
      end
    end

    def cache_tables_when_read
      File.open(cache_file_path, "w:UTF-8") { |file| file.puts(@nxscaes.to_json) }
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

