#encoding: utf-8 
class Account::CallbackDatasController < Account::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/account/callback_datas"
  set :layout, :"../../layouts/layout"

  before do
    authenticate!
  end

  get "/" do
    @callback_datas = current_user.callback_datas(:order => :updated_at.desc)
    
    if @callback_datas.count > 0
      last_modified @callback_datas.first.updated_at
      etag  md5_key(@callback_datas.first.updated_at.to_s)
    end

    haml :index, layout: settings.layout
  end

  get "/:id/response" do
    @callback_data = current_user.callback_datas.first(id: params[:id])

    haml :response
  end
end
