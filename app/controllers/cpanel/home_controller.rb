#encoding: utf-8 
class Cpanel::HomeController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/home"

  # root page
  get "/" do
    @cards    = Card.all
    @messages = Message.all

    haml :index, layout: :"../layouts/layout"
  end

  get "/store" do
    redirect "/account/store" if current_user
    @packages = Package.onsale

    haml :store, layout: :"../layouts/layout"
  end

  # redirect to cpanel
  get "/admin" do
    redirect "/account"
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
