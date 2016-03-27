# encoding: utf-8
class Demo::MoneyBallController < Demo::ApplicationController
  set :views, File.join(ENV['VIEW_PATH'], 'demo/money_ball')
  set :layout, :"../../layouts/layout"
  helpers Demo::MoneyBallHelper

  before do
    @page_header = '2016春季乐课力台球联赛'
    @current_stage = '淘汰赛'
    @current_season = '16-mar'
    set_seo_meta(@page_header, "八球，2016春季，赛事", "八球，2016春季，赛事，乐课力")
  end

  # Get /money_ball
  get '/' do
    @results = parse_rank

    haml :index, layout: settings.layout
  end

  private

  def parse_rank
    json_path = app_root_join("config/money_ball/#{@current_season}/rank.json")
    json_parse(File.read(json_path))
  end
end