#encoding: utf-8 
class Cpanel::MessagesController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/messages"

  # root page
  get "/" do
    @messages = Message.all

    haml :index, layout: :"../layouts/layout"
  end
end
