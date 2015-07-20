#encoding: utf-8 
class Account::WeixinersController < Account::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/account/weixiners"
  set :layout, :"../../layouts/layout"

  before do
    authenticate!
  end

  get "/" do
    haml :index, layout: settings.layout
  end
end
