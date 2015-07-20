#encoding: utf-8 
class HomeController < ApplicationController
  set :views, ENV["VIEW_PATH"] + "/home"

  # root page
  get "/" do
    redirect to("/cpanel") if current_user

    @users     = User.all
    @messages  = Message.all
    @weixiners = Weixiner.all
    haml :index, layout: :"../layouts/layout"
  end

  get "/about" do

    haml :about, layout: :"../layouts/layout"
  end

  # redirect to cpanel
  get "/admin" do
    redirect "/cpanel"
  end


  # redirect
  # login
  get "/login" do
    redirect "/user/login"
  end
  # register
  get "/register" do
    redirect "/user/register"
  end
end
