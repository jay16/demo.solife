# encoding: utf-8
class Demo::MoneyBallController < Demo::ApplicationController
  set :views, File.join(ENV['VIEW_PATH'], 'demo/money_ball')
  set :layout, :"../../layouts/layout"

  before do
    set_seo_meta("台球八球", "八球，2016春季，赛事", "八球，2016春季，赛事")
  end

  # Get /demo/openfind
  get '/' do
    haml :index, layout: settings.layout
  end
end
