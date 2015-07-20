#encoding: utf-8 
class Account::MessagesController < Account::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/account/messages"
  set :layout, :"../../layouts/layout"

  before do
    authenticate!
  end

  get "/" do
    haml :index, layout: settings.layout
  end
end
