# encoding: utf-8
source 'https://rubygems.org'

if defined? Encoding
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

gem 'sinatra', '~>1.4.7'
gem 'sinatra-contrib', '~>1.4.2'
gem 'sinatra-flash', '~>0.3.0'
gem 'sinatra-logger', '~>0.1.1'
gem 'sinatra-synchrony', '~>0.4.1'
gem 'emk-sinatra-url-for', '~> 0.2.1'

# assets
gem 'json', '~>1.8.3'
gem 'haml', '~>4.0.7'
gem 'therubyracer', '~>0.12.2'

gem 'unicorn', '~>5.0.1'
gem 'unicorn-worker-killer', '~>0.4.4'
gem 'rake', '~>11.1.1'
gem 'settingslogic', '~>2.0.9'
gem 'httparty', '~>0.13.7'
gem 'rack-mini-profiler', '~>0.9.9.2'
gem 'activesupport', '~>4.2.5'

gem 'redis', '~>3.2.2'
gem 'redis-namespace', '~>1.5.2'
gem 'sidekiq', '~>4.0.2'

# demo
gem 'nokogiri', '~>1.6.7'
gem 'spreadsheet', '=0.9.0'
gem 'rubyzip', '~> 1.1.4'
gem 'zip-zip', '~>0.3'

return unless `uname -s`.strip.eql?('Darwin')

group :development do
  gem 'whenever', '~>0.9.4', require: false
  gem 'awesome_print', '~>1.6.1'
  gem 'pry', '~>0.10.3'
  gem 'capistrano', '~>3.4.0'
  gem 'net-ssh', '~>2.7.0'
  gem 'net-scp', '~>1.2.1'
  gem 'guard-livereload', '~>2.5.2', require: false
  gem 'derailed', '~>0.1.0'
  gem 'rubycritic', '~>2.8.0', require: false
  gem 'rubocop', '~>0.38.0', require: false
  gem 'jshintrb', '~>0.3.0'
end
group :test do
  gem 'rack-test', '~>0.6.3'
  gem 'rspec', '~>3.4.0'
  gem 'factory_girl', '~>4.5.0'
  gem 'capybara', '~>2.6.2'
  gem 'poltergeist', '~>1.9.0'
  gem 'database_cleaner', '~>1.5.1'
  gem 'simplecov', '~>0.11.2', require: false
end
