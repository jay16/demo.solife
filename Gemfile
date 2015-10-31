#encoding: utf-8
if `uname -s`.strip.eql?("Darwin")
  source "https://ruby.taobao.org"
else
  source "https://rubygems.org"
end

if defined? Encoding
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

gem "sinatra", "~>1.4.5"
gem "sinatra-contrib", "~>1.4.2"
gem "sinatra-flash", "~>0.3.0"
gem "sinatra-advanced-routes", :require => "sinatra/advanced_routes"
gem "sinatra-logger", "~>0.1.1"
# This project is now part of sinatra-contrib.
# gem "sinatra-reloader" 

gem "actionmailer", "~>4.1.9"
gem "warden", "~>1.2.3"
gem "sinatra_more", "~>0.3.43"

gem "lazy_high_charts"

#db
gem "dm-core", "~>1.2.1"
gem "dm-migrations", "~>1.2.0"
gem "dm-validations", "~>1.2.0"
gem "dm-aggregates", "~>1.2.0"
gem "dm-timestamps", "~>1.2.0"
gem "dm-sqlite-adapter", "~>1.2.0"

#assets
gem "json", "~>1.8.2"
gem "haml", "~>4.0.5"
gem "sass", "~>3.3.7"
gem "therubyracer", "~>0.12.1"
gem "coffee-script", "~>2.2.0"

gem "unicorn", "~>4.8.3"
gem "rake", "~>10.3.2"
gem "settingslogic", "~>2.0.9"
gem "httparty", "~>0.13.3"

# demo
gem "nokogiri", "~>1.6.2.1"
gem "spreadsheet", "~>0.9.0"
gem "rubyzip", '~> 1.1.4'
gem 'zip-zip', "~>0.3"
gem "alipay_dualfun", :github => "happypeter/alipay_dualfun"

# for erb operation
# gem "tilt", "~>1.4.1"

group :development do
  gem "qiniu", "~>6.3.2"
  gem "net-ssh", "~>2.7.0"
  gem "net-scp", "~>1.2.1"
end
group :test do
  gem 'hashie', '~>2.0'
  gem 'rest-client', '~>1.7.3'
  gem "rack-test", "~>0.6.2"
  gem "rspec", "~>2.14.1"
  gem "factory_girl", "~>4.5.0"
  gem "capybara", "~>2.2.1"
  gem "poltergeist", "~>1.6.0"
  gem "database_cleaner", "~>1.4.1"
end if `uname -s`.strip.eql?("Darwin")
