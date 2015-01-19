#encoding: utf-8 
class Cpanel::UsersController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/users"

  # root page
  get "/" do
    @users     = User.all

    haml :index, layout: :"../layouts/layout"
  end
end
