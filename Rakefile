#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

$:.unshift(File.dirname(__FILE__))

task :default => [:environment]

desc "set up environment for rake"
task :environment => "Gemfile.lock" do
  ENV["RACK_ENV"] ||= "production"
  require File.expand_path('../config/boot.rb', __FILE__)
  eval "Rack::Builder.new {( " + File.read(File.expand_path('../config.ru', __FILE__)) + "\n )}"
end

desc "set up environment for weixin send group message"
task :simple do
  require "open-uri"
  require "json"
  require "settingslogic"

  @options ||= {}
  @options[:rack_env] = ENV["RACK_ENV"] ||= "production"
  ENV["APP_ROOT_PATH"] = @options[:app_root_path] = Dir.pwd
  load "%s/app/models/settings.rb" % @options[:app_root_path]
  require File.expand_path('../config/boot.rb', __FILE__)

  def base_on_root_path(path)
    if @options.has_key?(:app_root_path)
      File.join(@options[:app_root_path], path)
    else
      raise "[dangerous] @options missing key - :app_root_path"
    end
  end

  @options[:weixin_app_id]     = Settings.weixin.solife.app_id
  @options[:weixin_app_secret] = Settings.weixin.solife.app_secret
  @options[:weixin_base_url]   = "https://api.weixin.qq.com/cgi-bin"

  puts @options
end

desc "Sinatra App routes list"
task :routes => :environment do
  if Sinatra::Application.descendants.any?
    # Classic application structure
    applications = Sinatra::Application.descendants
  elsif Sinatra::Base.descendants.any?
    # Modular application structure
    applications = Sinatra::Base.descendants
  else
    abort("Cannot find any defined routes.....")
  end

  applications.each do |app|
    app_name, routes = app.to_s, app.routes

    puts "\nApplication: #{app_name}\n"
    routes.each do |verb,handlers|
      next if verb.downcase.eql?("head")

      puts "\n#{verb}:\n"
      handlers.each do |handler|
        route_text = handler[0].source.to_s.scan(/\\A(.*?)\\z/).flatten[0]
        # deal with dot `.`
        route_text.gsub!(/\(\?:\\\.\|%2\[Ee\]\)/, ".")
        # deal with params `:id` 
        # #TODO only for **one** params
        handler[1].each do |param| route_text.sub!(/\(.*\)/, ":#{param}")
        end unless handler[1].empty?

        puts route_text
      end
    end
  end
end
Dir.glob('lib/tasks/*.rake').each { |file| load file }
