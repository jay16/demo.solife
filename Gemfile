#encoding: utf-8
source "http://ruby.taobao.org"

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

#db
gem "dm-core", "~>1.2.1"
gem "dm-migrations", "~>1.2.0"
gem "dm-validations", "~>1.2.0"
gem "dm-aggregates", "~>1.2.0"
gem "dm-timestamps", "~>1.2.0"
gem "dm-sqlite-adapter", "~>1.2.0"

#assets
gem "json"
gem "haml", "~> 4.0.5"
gem "sass", "~>3.3.7"
gem "therubyracer", "~>0.12.1"
gem "coffee-script", "~>2.2.0"

#gem "passenger", "~>4.0.53"
#gem "thin", "~>1.6.2"
gem "unicorn", "~>4.8.3"
gem "capistrano", "~>2.15.5"
gem "rake", "~>10.3.2"
gem "settingslogic", "~>2.0.9"
gem "rest-client", "~>1.7.2"

#代码覆盖率
#rake stats

# for erb operation
gem "tilt", "~>1.4.1"

group :development do
  gem "qiniu", "~>6.3.2"
  gem "net-ssh", "~>2.7.0"
  gem "net-scp", "~>1.2.1"
end
group :test do
  gem "rack-test", "~>0.6.2"
  gem "rspec", "~>2.14.1"
  gem "factory_girl", "~>4.4.0"
  gem "jasmine", "~>2.0.2"
end
