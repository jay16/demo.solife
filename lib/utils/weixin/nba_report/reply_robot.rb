#encoding: utf-8
require "erb"
require "json"
require "timeout"
require "lib/utils/weixin/weixin_utils.rb"
require "lib/utils/weixin/solife/nxscae.rb"

module Sinatra
  module NBAReport
    module ReplyRobot 
      # command parser
      class Command 
        attr_reader :key, :command, :raw_cmd, :exec_cmd
        def initialize(message, options={})
          @message  = message
          @raw_cmd  = message.content.to_s.strip
          @options  = options
        end

        def self.exec(raw_cmd, options)
          reply = new(raw_cmd, options)
          reply.handler
        end

        def handler
          # 匹配 是否包含 - NBA球员名称，返回得分、失误、助攻等信息
          "内测中..."
        end
        
        # help menu
        def help
          "干货正在筹备中，当前仅提供一些简单服务..^_^"
        end
      end # Command

      class Parser
        def initialize(message, options={})
          @message = message
          @options = options
        end

        def handler
          case @message.msg_type
          when "text"  then
            Command.exec(@message, @options)
          when "event" then 
            _deal_with_weixin_event(@message)
          else 
            "类型为[%s],暂不支持!" % @message.msg_type
          end
        end

        def _deal_with_weixin_event(message)
          case message.event.downcase
          # [关注]
          when "subscribe"
            message.weixiner.update(status: @message.event)
            begin
              ::Timeout::timeout(4) do # weixin limit 5s callback
                ::WeixinUtils::Operation.generate_weixiner_info(@message.weixiner)
              end
            rescue => e
              puts e.message
              puts "Error#weixiner info get failed."
            end

            "感谢您关注[NBA报表]\n干货正在筹备中，当前仅提供一些简单服务..^_^"

          # [取消关注]
          when "unsubscribe"
            message.weixiner.update(status: @message.event)
            
            "期待您的再次关注"

          # 微信菜单[点击]响应处理
          when "click"
            case message.event_key.downcase
            when "personal_report"
              @message.weixiner.personal_report
            else
              "click#%s TODO" % @message.event_key
            end

          # 微信菜单[链接跳转]回调
          when "view"
            "event#view TODO"
          end
        end

        def self.exec(message, options)
          parser = new(message, options)
          respond = parser.handler || ""
          respond.force_encoding("UTF-8")
        end
      end

      module ReplyHelpers
        def reply_robot(message)
          options = {
            :weixin_name => settings.weixin_name,
            :weixin_desc => settings.weixin_desc,
            :root_path   => settings.root_path
          }
          Sinatra::NBAReport::ReplyRobot::Parser.exec(message, options)
        end
      end

      def self.registered(robot)
        robot.set     :weixin_name,      "NAME"
        robot.set     :weixin_desc,      "DESC"
        robot.helpers  ReplyHelpers
      end
    end # ReplyRobot
  end
  register NBAReport::ReplyRobot
end
