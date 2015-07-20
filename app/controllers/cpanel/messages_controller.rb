﻿#encoding: utf-8 
class Cpanel::MessagesController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/messages"
  set :layout, :"../../layouts/layout"

  # root page
  get "/" do
    @messages = Message.all(:order => :updated_at.desc)

    if @messages.count > 0
      last_modified @messages.first.updated_at
      etag  md5_key(@messages.first.updated_at.to_s)
    end

    haml :index, layout: settings.layout
  end
end
