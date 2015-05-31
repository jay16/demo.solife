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
      simulator_browser = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.81 Safari/537.36"

      timestamp = Time.now.strftime("%y%m%d%H")
      cachefile = "%s/tmp/nxscae-stock.%s.json" % [options[:app_root],timestamp]

      unless File.exist?(cachefile)
        response = RestClient.post options[:nxscae_stock_url], { user_agent: simulator_browser, :content_type => :json }
        hash = JSON.parse(response.body)
      else
        hash = JSON.parse(IO.read(cachefile))
      end

      products = hash["tables"]
      products = products.find_all do |product|
        is_what_i_want = true
        keywords.each do |keyword|
          unless product["fullname"] =~ /#{keyword}/
            is_what_i_want = false
            break
          end
        end
        is_what_i_want
      end unless keywords.empty?

      raw_result = products.map do |product|
        <<-`HEREDOC`
        echo "藏品简称: #{product['fullname']}"
        echo "今开盘价: #{product['OpenPrice']}"
        echo "最新价格: #{product['CurPrice']}"
        HEREDOC
      end.join("\n")

      <<-`HEREDOC`
        echo "关键字: #{keywords.join(",")}"
        echo "搜索到 #{products.count} 条结果"
        echo ""      
        echo "#{raw_result}"
        echo ""
        echo "nxscae时间:"
        echo "#{hash['time']}"
      HEREDOC
    end
  end
end


