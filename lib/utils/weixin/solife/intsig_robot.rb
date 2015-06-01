#encoding: utf-8
require "rest_client"
require "open-uri"

module Sinatra
  module IntsigRobot 
    # command instance methods
    module InstanceMethods
      def write_local_file file_path, &block 
        File.open(file_path, "wb") do |file|
          yield(file)
        end
      end
      def handler
        # don't modify
        user_agent = "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-us) AppleWebKit/523.10.6 (KHTML, like Gecko) Version/3.0.4 Safari/523.10.6"
        boundary = "0123456789ABLEWASIEREISAWELBA9876543210"
        content_type = "multipart/form-data; boundary=%s" % boundary
        header = { "Content-Type" => content_type, "User-Agent" => user_agent }

        url = "http://bcr2.intsig.net/BCRService/BCR_Crop?user=#{@intsig_user}&pass=#{@intsig_pass}&lang=15"

        # base info
        timestamp = Time.now.strftime("%Y%m%d%H%M%S%L")
        public_path = File.join(@root_path, "public")

        # download image form weixin server
        image_path = File.join(public_path, "images", timestamp+".jpg")
        write_local_file image_path do |file| 
          file.puts open(@message.pic_url).read
        end

        # trigger intsig api get cvf file stream data
        params = {upfile: File.new(image_path, 'rb')}
        response = RestClient.post url, params, header

        # write stream data to file
        vcf_name = "%s-%s.vcf" % [response.code.to_s, timestamp]
        vcf_path = File.join(public_path, "vcfs", vcf_name)
        if response.code == 200
          write_local_file vcf_path do |file| 
            file.puts response.body
          end
          @message.card.update({ intsig: vcf_name, intsig_response: "200" })
        else
          @message.card.update(intsig_response: "%d-%s" % [response.code, response.body])
        end
      end

    end
    class Intsig
      include InstanceMethods
      def initialize(message, options)
        @message     = message
        @intsig_user = options[:intsig_user]
        @intsig_pass = options[:intsig_pass]
        @root_path   = options[:root_path]
      end

      def self.exec(message, options)
        intsig = new(message, options)
        intsig.handler
      end
    end

    module IntsigHelpers
      def intsig_robot(message)
        options = {
          :intsig_user => settings.intsig_user,
          :intsig_pass => settings.intsig_pass,
          :root_path   => settings.root_path
        }
        Sinatra::IntsigRobot::Intsig.exec(message, options)
      end
    end

    def self.registered(robot)
      robot.set     :intsig_user,     "USER"
      robot.set     :intsig_pass,     "PASS"
      robot.set     :root_path,       "ROOT"
      robot.helpers  IntsigHelpers
    end
  end # IntsigRobot
  register IntsigRobot
end
