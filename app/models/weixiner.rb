#encoding: utf-8
require "model-base"
class Weixiner
    include DataMapper::Resource
    include Utils::DataMapper::Model
    extend  Utils::DataMapper::Model
    include Utils::ActionLogger

    property :id  , Serial 
    # 微信公众号名称
    property :name, String, required: true, default: "solife"
    # 微信公众号id
    property :uid,    String, required: true, unique: true
    property :status, String, default: "subscribe"

    belongs_to :user, required: false
    has n, :messages   # 微信消息
    has n, :callbacks  # 回调函数 
    has n, :callback_datas, through: :callbacks # 回调数据
    has 1, :weixiner_info

    def head_img_url
      default_headimgurl = "/images/headimgurl.jpeg"
      headimgurl = self.weixiner_info ? self.weixiner_info.headimgurl.strip : default_headimgurl
      headimgurl.empty? ? default_headimgurl : headimgurl
    end

    def nick_name
      self.weixiner_info ? self.weixiner_info.nickname : "TODO"
    end

    def personal_report
      _messages = self.messages
      message_count = _messages.count rescue 0
      today_s_count = _messages.all(:created_on => Time.now).count rescue 0
      callback_count = self.callbacks.count rescue 0
      callback_data_count = self.callbacks.inject(0) { |sum, cb| sum += cb.callback_datas.count } rescue 0
      report = "数据统计"
      report << "\n消息数量: %d" % message_count 
      report << "\n今日消息: %d" % today_s_count unless today_s_count.zero?
      report << "\n回调函数: %d" % callback_count unless callback_count.zero?
      report << "\n回调数据: %d" % callback_data_count unless callback_data_count.zero?
      report << "\n感谢您的使用/::P"
    end

    # instance methods
    def human_name
      "微信用户"
    end
end
