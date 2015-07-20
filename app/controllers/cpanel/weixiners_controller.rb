#encoding: utf-8 
class Cpanel::WeixinersController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/weixiners"
  set :layout, :"../../layouts/layout"

  # root page
  get "/" do
    @weixiners = Weixiner.all(:order => :updated_at.desc)

    last_modified @weixiners.first.updated_at
    etag  md5_key(@weixiners.first.updated_at.to_s)

    haml :index, layout: settings.layout
  end
end
