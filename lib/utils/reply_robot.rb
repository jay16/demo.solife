#encoding: utf-8
require "erb"
require "json"

module Sinatra
  module ReplyRobot 
    # command parser
    class Command 
      attr_reader :key, :command, :raw_cmd, :exec_cmd
      def initialize(message)
        @message  = message
        @result   = []
        @raw_cmd  = message.content.to_s.strip
      end
      def self.exec(raw_cmd)
        reply = new(raw_cmd)
        reply.handler
      end
      def handler
        if @raw_cmd =~ /^\?/ or @raw_cmd.force_encoding('UTF-8').start_with?("？")
            help
        elsif @raw_cmd =~ /^账户绑定\s+/
          email = @raw_cmd.split[1]
          user = ::User.first(email: email)
          if user.nil?
            status = "帐户绑定失败."
            status << "原因: 帐户(%s)不存在." % email
          else
            state = @message.weixiner.update(user_id: user.id)
            status = "帐户绑定: %s" % (state ? "成功" : "失败")
          end
        else
          "handler#todo#{@raw_cmd}"
        end
      end
      # help menu
      def help
        "帮助菜单:\n 说明你想记录的文字、语音、图片、位置..."
      end
    end # Command

    class Parser
      def initialize(message)
        @message     = message
        @msg_type_hash = {
          "text"     => "文本",
          "news"     => "新闻",
          "music"    => "音乐",
          "image"    => "图片",
          "link"     => "链接",
          "video"    => "视频",
          "voice"    => "音频",
          "location" => "位置",
          "event"    => "事件"
        }
      end

      def handler
        case @message.msg_type
        when "voice" then
          result = %Q{"%s"\n\n} % @message.recognition.force_encoding('UTF-8')
          result += "分解:\n"
          if phantom = @message.phantom
            result += phantom.process
            if change_log = ChangeLog.first(remark: "message#%d" % @message.id)
              result += "\n\n hi %s" % change_log.author
              result += "\n更新日志创建成功."
            end
          else
            result += "未创建"
          end
          return result
        when "text"  then 
          Command.exec(@message)
        when "event" then 
          case @message.event.downcase
          when "subscribe"
            @message.weixiner.update(status: @message.event)
            "你好，感谢您参与[小6语记]\n如有疑问请输入: ?"
          when "unsubscribe"
            @message.weixiner.update(status: @message.event)
            "期待您的再次关注"
          when "click"
            case @message.event_key.downcase
            when "personal_report"
              @message.weixiner.personal_report
            else
              "click#%s TODO" % @message.event_key
            end
          when "view"
            cache_file= File.join(ENV["APP_ROOT_PATH"], "tmp/weixin_menu_view.cache")
            command = "echo '%s,%s' >> %s" % [Time.now.to_i, @message.from_user_name, cache_file]
            `#{command}`
            return "event#view TODO"
          end
        else 
          "类型为[%s],暂不支持!" % @message.msg_type
        end
      end

      def self.exec(message)
        parser = new(message)
        parser.handler
      end
    end

    module ReplyHelpers
      def reply_robot(message)
        Sinatra::ReplyRobot::Parser.exec(message)
      end
    end

    def self.registered(robot)
      robot.set     :weixin_name,     "NAME"
      robot.set     :weixin_desc,     "DESC"
      robot.helpers  ReplyHelpers
    end
  end # ReplyRobot
  register ReplyRobot
end
