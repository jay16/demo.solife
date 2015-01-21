#encoding: utf-8 
class Account::CallbackDatasController < Account::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/account/callback_datas"

  before do
    authenticate!
  end

  get "/" do
    @callback_datas = current_user.callback_datas

    haml :index, layout: :"../layouts/layout"
  end

  get "/:id/response" do
    @callback_data = current_user.callback_datas.first(id: params[:id])

    haml :response
  end
end
