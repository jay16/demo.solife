#encoding: utf-8
ENV["RACK_ENV"] = "test"
require File.expand_path '../../config/boot.rb', __FILE__
require 'capybara'
require 'capybara/dsl'
require "capybara/rspec"
require 'capybara/poltergeist'
require "rack/test"
require "digest/md5"
require "factory_girl"

module RSpecMixin
  include Rack::Test::Methods
  include Capybara::DSL

  Capybara.app = eval("Rack::Builder.new {( %s\n )}" % IO.read(File.join(ENV["APP_ROOT_PATH"], "config.ru")))

  Dir[File.join(ENV["APP_ROOT_PATH"], "spec/factories/*.rb")].each { |f| require f }
  # brew install phantomjs
  Capybara.javascript_driver = :poltergeist

  def app; Capybara.app end
end

RSpec.configure do |config|
  config.include RSpecMixin

  config.before(:each) do
    DatabaseCleaner.orm = :data_mapper
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
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
  last_request.env["REQUEST_PATH"] || "/"
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

def is_network_available
  begin
    RestClient.get("http://www.baidu.com")
    return true
  rescue
    return false
  end
end

def it_with_network(desc, &block)
  unless is_network_available
    block = Proc.new { pending("need network environment") }
  end
  it(desc, &block)
end
