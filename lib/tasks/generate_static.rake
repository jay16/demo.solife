#encoding: utf-8
require "erb"
require "tilt"
require "tilt/haml"

desc "generate static template for less resource useage"
namespace :gs do

  def run_operation(info, &block)
    _time = Time.now
    success = yield block
    tlast = ((Time.now - _time).to_f * 1000).to_i

    state = (success == false ? "[Failed]" : "[done]")
    printf("%-10s - %-20s [%sms]\n", state, info, tlast)
  end

  def generate_html(output, target_file)
    File.open(target_file, "wb+") { |file| file.puts output }
  end

  task :markdown=> :environment do
    require "lib/utils/tilt.rb"
    include Utils::Tiltor
    require "config/boot.rb"
    include ApplicationHelper
    include HomeHelper
    include TeasHelper
    include Sinatra::FormHelpers
    root_path = ENV["APP_ROOT_PATH"]
    set :root_path, root_path
    set :views, ""

    puts markdown(:"markdown", :layout_engine => :haml, :layout => :"app/views/layouts/layout")
  end

  desc "generate static html,in order to reduce pressure on server"
  task :home_page => :environment do
    root_path = ENV["APP_ROOT_PATH"]
    $:.unshift(root_path)
    # scope - for binding
    require "config/boot.rb"
    include ApplicationHelper
    include HomeHelper
    include TeasHelper
    include Sinatra::FormHelpers
    # extract template from sinatra
    require "lib/utils/tilt.rb"
    include Utils::Tiltor

    home_path = "%s/%s" % [root_path, "app/views/home"]
    @teas = Tea.all(:onsale => true)

    set :root_path, root_path
    set :views, "app/views/cpanel/home"
    set :layout, :"../layouts/layout"
    run_operation "购物车(web版)" do
      generate_html(haml(:"cart.template"), join_path(home_path, "cart.erb"))
    end

    run_operation "购物车(移动端)" do
      generate_html(haml(:"mobile_cart.template"), join_path(home_path, "mobile_cart.erb"))
    end

    set :layout, :"../layouts/layout.v2"
    run_operation "首页" do
      generate_html(erb(:"home.template"), join_path(home_path,"home.erb"))
    end

    @teas = Tea.all(:order => [:onsale.desc]) #:limit => 20
    set :views, "app/views/cpanel/teas"
    set :layout, :"../layouts/layout"
    fixtures_path = "%s/%s" % [root_path, "spec/javascripts/fixtures"]
    run_operation "茶品主页(测试)" do
      generate_html(haml(:index), join_path(fixtures_path, "teas.html"))
    end
  end
end
