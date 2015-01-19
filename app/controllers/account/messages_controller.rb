#encoding: utf-8 
class Account::MessagesController < Account::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/account/messages"

  before do
    authenticate!
  end

  get "/" do
    haml :index, layout: :"../layouts/layout"
  end
end
