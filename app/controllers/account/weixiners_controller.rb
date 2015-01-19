#encoding: utf-8 
class Account::WeixinersController < Account::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/account/weixiners"

  before do
    authenticate!
  end

  get "/" do
    haml :index, layout: :"../layouts/layout"
  end
end
