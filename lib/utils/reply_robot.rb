#encoding: utf-8
require "yaml"
require "erb"

module Sinatra
  module ReplyRobot 
    # command instance methods
    module InstanceMethods
      def load_yaml(file_path)
        file_contents = File.read(file_path)
        YAML.load(ERB.new(file_contents).result).to_hash
      end
    end
    # only for command
    module CommandInstanceMethods
      def cmd_query(options)
        command, index, rest = options
        card = @message.weixiner.cards.first(index: index)
        if card
          "录入状态: %s完成.\n" % (card.is_over ? "" : "未") + 
          "上传时间: %s" % card.created_at.strftime("%Y-%m-%d %H:%M")
        else
          "未查找名片ID: %d." % index
        end
      end
    end
    # command parser
    class Command 
      include InstanceMethods
      include CommandInstanceMethods
      attr_reader :key, :command, :raw_cmd, :exec_cmd
      def initialize(message, yaml)
        @message  = message
        @result   = []
        @raw_cmd  = message.content 
        @commands = yaml["command"]
      end
      def self.exec(raw_cmd, yaml)
        reply = new(raw_cmd, yaml)
        reply.handler
      end
      def handler
        @response = find_key ? parse : help
        result = []
        if @exec_cmd
          result.push "执行命令:\n %s" % @exec_cmd 
        else
          result.push "命令无效.\n命令列表:\n"
        end
        result.push @response
        result.join("\n")
      end
      # whether command exist in yaml
      def find_key
        @key = @commands.keys.find do |key|
          regexp = @commands[key]["regexp"]
          Regexp.new(regexp) =~ @raw_cmd
        end
      end
      # parse command when @key exist
      def parse
         regexp = @commands[@key]["regexp"]
         Regexp.new(regexp) =~ @raw_cmd
         @exec_cmd = $&
         send(:cmd_query, @exec_cmd.split)
      end
      # help menu
      def help
        @commands.keys.map do |key|
          "c%s %s" % [key, @commands[key]["human"]]
        end.join("\n")
      end
    end # Command

    class Parser
      include InstanceMethods
      def initialize(message, weixin_yaml)
        @message     = message
        @weixin_yaml = weixin_yaml
        @yaml        = load_yaml(@weixin_yaml)
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
        when "text"  then 
          Command.exec(@message, @yaml)
        when "image" then 
          "%s\n名片ID: %s\n" % [@yaml["image"], @message.card.index]
        when "event" then 
          @message.weixiner.update(status: @message.event)
          @yaml["event"][@message.event]
        when "voice" then
          "感谢您的[%s]反馈." % @msg_type_hash["voice"]
        when "video" then
          "感谢您的[%s]反馈." % @msg_type_hash["video"]
        else 
          "类型为[%s],暂不支持!" % @message.msg_type
        end
      end

      def self.exec(message, weixin_yaml)
        parser = new(message, weixin_yaml)
        parser.handler
      end
    end

    module ReplyHelpers
      def reply_robot(message)
        Sinatra::ReplyRobot::Parser.exec(message, settings.weixin_yaml)
      end
    end

    def self.registered(robot)
      robot.set     :weixin_name,     "NAME"
      robot.set     :weixin_desc,     "DESC"
      robot.set     :weixin_yaml,     "DESC"
      robot.helpers  ReplyHelpers
    end
  end # ReplyRobot
  register ReplyRobot
end
