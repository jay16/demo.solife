#encoding: utf-8
ENV["RACK_ENV"] = "test"
#require 'capybara/dsl'
#require "capybara/rspec"
require "rack/test"
require File.expand_path '../../config/boot.rb', __FILE__
require "digest/md5"
#require "factory_girl"
#require File.expand_path '../factories/transaction_factory.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  #include Capybara::DSL

  def app() 
    # shell = %Q{cd %s/db && cp -f %s_development.db %s_test.db} % [ENV["APP_ROOT_PATH"], ENV["APP_NAME"], ENV["APP_NAME"]]
    # raise "Error: shell execute fail - \n#{shell}" if not system(shell)

    rackup  = File.read("%s/config.ru" % ENV["APP_ROOT_PATH"])
    builder = "Rack::Builder.new {( %s\n )}" % rackup
    eval builder
  end

  #Capybara.app = ApplicationController 
  #Capybara.register_driver :selenium do |app|
  #  #profile = Selenium::WebDriver::Chrome::Profile.new
  #  #profile['extensions.password_manager_enabled'] = false
  #  Capybara::Selenium::Driver.new(app, :browser => :chrome)
  #end
  #Capybara.javascript_driver = :chrome
end

RSpec.configure do |config|
  config.include RSpecMixin 
  #config.include Capybara::DSL
end


def example_url
  "http://example.org"
end

def redirect_url path
  "%s%s" % [example_url, path]
end

def remote_ip
  last_request.env["REMOTE_ADDR"] || "n-i-l"
end

def remote_path
  request.env["REQUEST_PATH"] || "/"
end

def remote_browser
  last_request.env["HTTP_USER_AGENT"] || "n-i-l"
end

def uuid(str)
  str += Time.now.to_f.to_s
  md5_key(str)
end
def md5_key(str)
  Digest::MD5.hexdigest(str)
end
def sample_3_alpha
  (('a'..'z').to_a + ('A'..'Z').to_a).sample(3).join
end

# for weixin test
require "hashie"
require 'digest/sha1'
def sign_params params = {}, token
  sign = Digest::SHA1.hexdigest([token, params[:timestamp], params[:nonce]].collect(&:to_s).compact.sort.join)
  params.merge(signature: sign)
end

def weixin_url(url, append_params = {}, token)
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
      nodes << "<#{k}>#{v}</#{k}>" unless k.to_s == 'cdatas'
    end

    self.cdatas.each_pair do |k,v|
      nodes << "<#{k}><![CDATA[#{v}]]></#{k}>"
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
