#encoding: utf-8
require "hashie"
require 'digest/sha1'
# extract code and logic from [wecheat](!https://github.com/xixilive/wecheat)

module Weixin
  module Spec
    module Utils
      extend self

      def sign_params(params={}, token)
        puts params.to_s
        sign = Digest::SHA1.hexdigest([token, params[:timestamp], params[:nonce]].collect(&:to_s).compact.sort.join)
        params.merge(signature: sign)
      end

      def base_url(url, token, append_params={})
        puts append_params.to_s
        signed_params = sign_params({
          timestamp: Time.now.to_i,
          nonce: rand_secret
        }.merge(append_params), token)
        segments = [url, URI.encode_www_form(signed_params)]
        (url.to_s.include?('?') ? segments.join("&") : segments.join("?")).gsub(/(\?\&)|(\&\?)/,'?')
      end


      class MessageBuilder < Hashie::Mash
        def to_xml
          nodes = []

          self.each_pair do |k,v|
            nodes << "<#{k}>#{v}</#{k}> " unless k.to_s == 'cdatas'
          end

          self.cdatas.each_pair do |k,v|
            nodes << "<#{k}><![CDATA[#{v}]]></#{k}> "
          end
          "<xml>#{nodes.join}</xml>"
        end

        def cdata name, value
          self.cdatas ||= Hashie::Mash.new
          self.cdatas[name] = value
        end

        def to_hash
          h = super
          cdatas = h.delete('cdatas') || {}
          h.merge(cdatas)
        end
      end

      def chars
        @chars ||= (('a'..'z').to_a | ('A'..'Z').to_a | (0..9).to_a)
      end

      def message_builder(message)
        MessageBuilder.new.tap do |b|
          b.cdata 'ToUserName', "ToUserName"
          b.cdata 'FromUserName', "FromUserName"
          b.cdata 'MsgType', "text"
          b.CreateTime Time.now.to_i
          b.MsgId Time.now.to_i
          b.cdata 'Content', message
        end.to_xml
      end

      def rand_openid
        chars.shuffle.slice(0,28).join
      end

      def rand_appid
        chars.shuffle.slice(0,16).unshift('wx').join.downcase
      end

      def rand_secret
        chars.shuffle.slice(0,32).join.downcase
      end

      def rand_token
        rand_openid + rand_openid
      end
    end
  end
end
