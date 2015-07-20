#encoding: utf-8 
class Account::CallbacksController < Account::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/account/callbacks"
  set :layout, :"../../layouts/layout"

  before do
    authenticate!
  end

  get "/" do
    @callbacks = current_user.callbacks(:order => :updated_at.desc)

    last_modified @callbacks.first.updated_at
    etag  md5_key(@callbacks.first.updated_at.to_s)

    haml :index, layout: settings.layout
  end

  # new
  get "/new/:uid" do
    weixiner = current_user.weixiners.first(uid: params[:uid])
    @callback = weixiner.callbacks.new

    haml :new, layout: settings.layout
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

    haml :copy, layout: settings.layout
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

    haml :show, layout: settings.layout
  end

  # edit
  get "/:id/edit" do
    @callback = Callback.first(id: params[:id]) 

    haml :edit, layout: settings.layout
  end

  # update
  post "/:id" do
    @callback = Callback.first(id: params[:id]) 
    @callback.update(params[:callback])

    redirect "/account/callbacks/%d" % @callback.id
  end
end
