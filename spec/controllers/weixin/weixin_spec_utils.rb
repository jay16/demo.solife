#encoding:utf-8
require "hashie"
require 'digest/sha1'
# extract code and logic from [wecheat](!https://github.com/xixilive/wecheat)

module Weixin
  module Spec
    module Utils
      extend self

      def sign_params(params={}, token)
        sign = Digest::SHA1.hexdigest([token, params[:timestamp], params[:nonce]].collect(&:to_s).compact.sort.join)
        params.merge(signature: sign)
      end

      def base_url(url, token, append_params={})
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
          "<xml>#{nodes.join}</xml>".force_encoding("UTF-8")
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

# weixin rspec methods


def weixin_message_test(url, message, expect_block, change_block)
  lambda {
    post url, message, content_type: 'text/xml; charset=utf-8'

    expect(last_response).to be_ok
    expect(last_response.headers['Content-Type']).to match(/application\/xml;\s*charset\=utf\-8/i)

    expect_block.()
  }.should {
    change_block.()
  }
end

def weixin_text_message_test(message, expect_messages)
  message = Weixin::Spec::Utils.message_builder(message)
  url = Weixin::Spec::Utils.base_url("/weixin/solife", Settings.weixin.solife.token, {})

  weixin_message_test(url, message, 
    -> { 
      receiver = message_receiver(last_response.body)

      expect(receiver.text?).to be(true)

      expect_messages = [expect_messages] unless expect_messages.is_a?(Array)
      expect_messages.each do |expect_message|
        if expect_message.is_a?(String)
          expect(receiver.content).to include(expect_message)
        else
          expect(receiver.content).to match(expect_message)
        end
      end
    }, 
    -> {
      change(Weixiner, :count).by(1)
      change(Message, :count).by(1)
  })
end
