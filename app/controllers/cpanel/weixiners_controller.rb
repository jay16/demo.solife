#encoding: utf-8 
class Cpanel::WeixinersController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/weixiners"

  # root page
  get "/" do
    @weixiners = Weixiner.all

    haml :index, layout: :"../layouts/layout"
  end
end
