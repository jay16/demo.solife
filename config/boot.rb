#encoding: utf-8
require "rubygems"

root_path = File.dirname(File.dirname(__FILE__))#File.expand_path("../../", __FILE__)
ENV["APP_NAME"]  ||= "solife-demo"
ENV["RACK_ENV"]  ||= "development"
ENV["ASSET_CDN"] ||= "false"
ENV["VIEW_PATH"]     = "%s/app/views" % root_path
ENV["APP_ROOT_PATH"] = root_path

begin
  ENV["BUNDLE_GEMFILE"] ||= "%s/Gemfile" % root_path
  require "rake"
  require "bundler"
  Bundler.setup
rescue => e
  puts e.backtrace &&  exit
end
puts "="*10
puts ENV["RACK_ENV"]

puts "="*10
Bundler.require(:default, ENV["RACK_ENV"])

# execute linux shell command
# return array with command result
# [execute status, execute result] 
def run_command(cmd)
  IO.popen(cmd) do |stdout|
    stdout.reject(&:empty?)
  end.unshift($?.exitstatus.zero?)
end 

status, *result = run_command("whoami")
if result[0].strip == "root"
  system("chown -R nobody:nobody #{root_path} && chmod -R 777 #{root_path}")
else
  warn "warning: [#{result[0].strip}] can't execute chown/chmod"
end

# 扩充require路径数组
# require 文件时会在$:数组中查找是否存在
$:.unshift(root_path)
$:.unshift("%s/config" % root_path)
$:.unshift("%s/lib/tasks" % root_path) 
%w(controllers helpers models).each do |path|
  $:.unshift("%s/app/%s" % [root_path, path])
end

require "lib/utils/action_logger.rb"
require "lib/utils/boot.rb"
include Utils::Boot

recursion_require("lib/utils/core_ext", /\.rb$/, root_path)

# config文夹下为配置信息优先加载
# modle信息已在asset-hanler中加载
# asset-hanel嵌入在application_controller
require "asset-handler"
require "form-helpers"
# base on model ActionLog

# helper will include into controller
# helper load before controller
recursion_require("app/helpers", /_helper\.rb$/, root_path)
recursion_require("app/controllers", /_controller\.rb$/, root_path, [/^application_/])

system("echo '%s' > %s" % [root_path, File.join(root_path, "tmp/app_root_path")])
system("echo '%s' > %s" % [File.join(root_path, "public/callbacks"), File.join(root_path, "tmp/callbacks_path")])
system("echo '%s' > %s" % [File.join(root_path, "public/change_logs"), File.join(root_path, "tmp/change_logs_path")])

