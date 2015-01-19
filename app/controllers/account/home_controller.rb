#encoding: utf-8 
class Account::HomeController < Account::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/account/home"

  before do
    authenticate!
  end

  get "/" do
    @weixiners = current_user.weixiners

    haml :index, layout: :"../layouts/layout"
  end
end
