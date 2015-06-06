#encoding: utf-8 
class Cpanel::MessagesController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/messages"
  set :layout, :"../../layouts/layout"

  # root page
  get "/" do
    @messages = Message.all

    haml :index, layout: settings.layout
  end
end
