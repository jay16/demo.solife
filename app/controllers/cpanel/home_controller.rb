#encoding: utf-8 
class Cpanel::HomeController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/home"
  set :layout, :"../../layouts/layout"

  # root page
  get "/" do
    @users     = User.all
    @weixiners = Weixiner.all
    @messages  = Message.all

    haml :index, layout: settings.layout
  end

end
