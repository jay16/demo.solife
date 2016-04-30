# encoding: utf-8
require 'rubygems'

root_path = File.dirname(File.dirname(__FILE__))
ENV['APP_NAME'] ||= 'demo.solife'
ENV['RACK_ENV'] ||= 'development'
ENV['ASSET_CDN'] ||= 'false'
ENV['STARTUP'] = Time.now.to_s
ENV['VIEW_PATH'] = '%s/app/views' % root_path
ENV['APP_ROOT_PATH'] = root_path
ENV['CACHE_NAMESPACE'] ||= 'yh'
ENV['REDIS_PID_PATH'] ||= %(#{root_path}/tmp/pids/redis.pid)
ENV['UNICORN_PID_PATH'] ||= %(#{root_path}/tmp/pids/unicorn.pid)

begin
  ENV['BUNDLE_GEMFILE'] ||= '%s/Gemfile' % root_path
  require 'rake'
  require 'bundler'
  Bundler.setup
rescue => e
  puts e.backtrace && exit
end
Bundler.require(:default, ENV['RACK_ENV'])

ENV['PLATFORM_OS'] = `uname -s`.strip.downcase

# 扩充require路径数组
# require 文件时会在$:数组中查找是否存在
$LOAD_PATH.unshift(root_path)
$LOAD_PATH.unshift('%s/config' % root_path)
$LOAD_PATH.unshift('%s/lib/tasks' % root_path)
%w(controllers helpers models).each do |path|
  $LOAD_PATH.unshift('%s/app/%s' % [root_path, path])
end
require "#{root_path}/app/models/settings.rb"

require 'lib/utils/boot.rb'
include Utils::Boot

require 'active_support'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/numeric'

require 'asset_handler'

# helper will include into controller
# helper load before controller
recursion_require('app/helpers', /_helper\.rb$/, root_path)
recursion_require('app/controllers', /_controller\.rb$/, root_path, [/^application_/])
recursion_require('app/workers', /_worker\.rb$/, root_path)
