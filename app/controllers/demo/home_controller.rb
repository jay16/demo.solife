#encoding: utf-8 
class Demo::HomeController < Demo::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/demo/home"
  set :layout, :"../../layouts/layout"
  
  before do
    set_seo_meta("实验室", "实验室, solife", "segment of jay's life.")
  end

  # /demo
  get "/" do
    haml :index, layout: settings.layout
  end
end
