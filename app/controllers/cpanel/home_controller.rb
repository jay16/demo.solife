#encoding: utf-8 
class Cpanel::HomeController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/home"

  # root page
  get "/" do
    @users     = User.all
    @weixiners = Weixiner.all
    @messages  = Message.all

    haml :index, layout: :"../layouts/layout"
  end

end
