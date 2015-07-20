#encoding: utf-8 
class Cpanel::UsersController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/users"
  set :layout, :"../../layouts/layout"

  # root page
  get "/" do
    @users = User.all(:order => :updated_at.desc)

    last_modified @users.first.updated_at
    etag  md5_key(@users.first.updated_at.to_s)

    haml :index, layout: settings.layout
  end
end
