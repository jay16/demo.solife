#encoding: utf-8
ENV["RACK_ENV"] = "test"
require File.expand_path '../../config/boot.rb', __FILE__
require 'capybara'
require 'capybara/dsl'
require "capybara/rspec"
require 'capybara/poltergeist'
require "rack/test"
require "digest/md5"
require 'simplecov'

module RSpecMixin
  include Rack::Test::Methods
  include Capybara::DSL

  Capybara.app, = Rack::Builder.parse_file File.join(ENV['APP_ROOT_PATH'], 'config.ru')

  Dir[File.join(ENV["APP_ROOT_PATH"], "spec/factories/*.rb")].each { |f| require f }

  # brew install phantomjs
  Capybara.javascript_driver = :poltergeist
  Capybara.register_driver :rack_test do |app|
    Capybara::RackTest::Driver.new(app, headers: { 'HTTP_USER_AGENT' => 'Capybara' })
  end

  def app
    Capybara.app
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include FactoryGirl::Syntax::Methods
  # config.syntax = :expect

  # Use color in STDOUT
  # config.color_enabled = true
  config.color = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate

  config.order = 'random'
end

def example_url
  "http://example.org"
end

def redirect_url path
  "%s%s" % [example_url, path]
end

def remote_ip
  last_request.env["REMOTE_ADDR"]
end

def remote_path
  last_request.env["REQUEST_PATH"]
end

def remote_browser
  last_request.env["HTTP_USER_AGENT"]
end

def uuid(str)
  str += Time.now.to_f.to_s
  md5_key(str)
end

def md5(str)
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

def http_cookie(is_admin = true)
  { 'HTTP_COOKIE' => %(authen=whatever) }
end

def default_user_agents
  {
    iphone: 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Mobile/9A334 Safari/7534.48.3',
    ipod: 'Mozilla/5.0 (iPod; CPU iPhone OS 5_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A405 Safari/7534.48.3',
    ipad: 'Mozilla/5.0 (iPad; CPU OS 5_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A405 Safari/7534.48.3',
    android: 'Mozilla/5.0 (Linux; U; Android 2.3.3; ja-jp; SonyEricssonX10i Build/3.0.1.G.0.75) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1',
    android_tablet: 'Mozilla/5.0 (Linux; U; Android 3.1; ja-jp; Sony Tablet S Build/THMAS10000) AppleWebKit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13',
    windows_phone: 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; KDDI-TS01; Windows Phone 6.5.3.5)',
    black_berry: 'BlackBerry9700/5.0.0.1014 Profile/MIDP-2.1 Configuration/CLDC-1.1 VendorID/220',
    ie7: 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727; InfoPath.1)',
    ie8: 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.04506.648)',
    ie9: 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)',
    ie10: 'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)',
    chrome: 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.75 Safari/535.7'
  }
end

def custom_user_agent(type)
  user_agent = default_user_agents[type]
  driver = Capybara.current_session.driver

  if driver.respond_to?(:add_headers)
    driver.add_headers('User-Agent' => user_agent)
  else
    driver.header('User-Agent', user_agent)
  end
end

def json_parse(body)
  JSON.parse(body).deep_symbolize_keys!
end

def demo_path(path)
  path
end