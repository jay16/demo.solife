ENV["RACK_ENV"] = "test"
#require 'capybara/dsl'
#require "capybara/rspec"
require "factory_girl"
require "rack/test"
require File.expand_path '../../config/boot.rb', __FILE__
require File.expand_path '../factories/transaction_factory.rb', __FILE__

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
