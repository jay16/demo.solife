#encoding: utf-8 
class HomeController < ApplicationController
  set :views, ENV["VIEW_PATH"] + "/home"

  # root page
  get "/" do
    redirect to("/cpanel") if current_user

    haml :index, layout: :"../layouts/layout"
  end

  get "/about" do
    etag  md5("/about static control")

    haml :about, layout: :"../layouts/layout"
  end

  # redirect to cpanel
  get "/admin" do
    redirect to("/cpanel")
  end

  # login
  get "/login" do
    redirect to("/user/login")
  end
  # register
  get "/register" do
    redirect to("/user/register")
  end
end
