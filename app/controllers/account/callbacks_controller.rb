#encoding: utf-8 
class Account::CallbacksController < Account::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/account/callbacks"

  before do
    authenticate!
  end

  get "/" do
    @callbacks = current_user.callbacks

    haml :index, layout: :"../layouts/layout"
  end

  # new
  get "/new/:uid" do
    weixiner = current_user.weixiners.first(uid: params[:uid])
    @callback = weixiner.callbacks.new

    haml :new, layout: :"../layouts/layout"
  end

  # copy
  get "/:id/copy" do
    callback  = current_user.callbacks.first(id: params[:id])
    @callback = Callback.new
    @callback.weixiner_id = callback.weixiner_id
    @callback.outer_url   = callback.outer_url
    @callback.token       = callback.token
    @callback.keyword     = callback.keyword
    @callback.desc        = callback.desc

    haml :copy, layout: :"../layouts/layout"
  end

  # create
  post "/" do
    @callback = Callback.new(params[:callback])
    @callback.save_with_logger

    redirect "/account/callbacks/%d" % @callback.id
  end

  # show
  get "/:id" do
    @callback = Callback.first(id: params[:id]) 

    haml :show, layout: :"../layouts/layout"
  end

  # edit
  get "/:id/edit" do
    @callback = Callback.first(id: params[:id]) 

    haml :edit, layout: :"../layouts/layout"
  end

  # update
  post "/:id" do
    @callback = Callback.first(id: params[:id]) 
    @callback.update(params[:callback])

    redirect "/account/callbacks/%d" % @callback.id
  end
end
