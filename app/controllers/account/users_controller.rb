#encoding: utf-8 
class Account::UsersController < Account::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/account/users"

  # get /user/login
  get "/login" do
    haml :login, layout: :"../../layouts/layout"
  end

  # logout
  # delete /user/logout
  get "/logout" do
    response.set_cookie "cookie_user_login_state", {:value=> "", :path => "/", :max_age => "2592000"}
    redirect "/"
  end

end
