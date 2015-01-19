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
end
