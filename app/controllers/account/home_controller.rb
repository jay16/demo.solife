#encoding: utf-8 
#require "lib/utils/weixin/weixin_utils.rb"
class Account::HomeController < Account::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/account/home"

  before do
    authenticate!
  end

  get "/" do
    @weixiners = current_user.weixiners
    #WeixinUtils::Operation.generate_weixiner_info(Weixiner.all)

    haml :index, layout: :"../layouts/layout"
  end
end
