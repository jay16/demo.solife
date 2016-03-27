#encoding: utf-8
require "fileutils"
require "logger"

class AssetHandler < Sinatra::Base

  configure do
    enable :logging, :static, :sessions 
    enable :method_override
    enable :coffeescript

    #Logger.class_eval { alias :write :"<<" }
    #logger_file = File.join(ENV["APP_ROOT_PATH"], "log/#{ENV["RACK_ENV"]}.log")
    #logger = ::Logger.new(::File.new(logger_file, "a+"))
    #use Rack::CommonLogger, logger

    set :root,  ENV["APP_ROOT_PATH"]
    set :views, ENV["VIEW_PATH"]
    set :public_folder, ENV["APP_ROOT_PATH"] + "/app/assets"
    set :js_dir,  ENV["APP_ROOT_PATH"] +  "/app/assets/javascripts"
    set :css_dir, ENV["APP_ROOT_PATH"] + "/app/assets/stylesheets"

    #set :erb, :layout_engine => :erb, :layout => :layout
    set :haml, :layout_engine => :haml, :layout => :"/app/views/layouts/layout"
    set :cssengine, "css"
  end 
  
  # 加载数据库及model
  # require "database.rb"
end
