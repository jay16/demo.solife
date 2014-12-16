#encoding: utf-8 
class Carder::UserController < Carder::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/carder/user"

  # get /user/login
  get "/login" do
    haml :login, layout: :"../../layouts/layout"
  end

  # login /user/login
  post "/login" do
    user = User.first(email: params[:user][:email])
    if user and user.password == md5_key(params[:user][:password])
      response.set_cookie "cookie_user_login_state", {:value=> user.email, :path => "/", :max_age => "2592000"}

      flash[:success] = "登陆成功"
      redirect request.cookies["cookie_before_login_path"] || "/carder"
    else
      response.set_cookie "cookie_user_login_state", {:value=> "", :path => "/", :max_age => "2592000"}

      flash[:warning] = "登陆失败"
      redirect "/carder/user/login"
    end
  end

  # register page
  # get /user/register
  get "/register" do
    @user ||= User.new

    haml :register, layout: :"../layouts/layout"
  end

  # post /user/register
  post "/register" do
    params[:user][:password] = md5_key(params[:user][:password])
    user = User.new(params[:user])

    if user.save
      flash[:success] = "hi %s, 注册成功，请登陆..." % user.email
      redirect "/carder/user/login"
    else
      msg = ["注册失败:"]
      format_dv_errors(user).each_with_index do |hash, index|
        msg.push("%d. %s" % [index+1, hash.to_a.join(": ")])
      end
      flash[:danger] = msg.join("<br>")
      redirect "/carder/user/register"
    end
  end

  # logout
  # delete /user/logout
  get "/logout" do
    response.set_cookie "cookie_user_login_state", {:value=> "", :path => "/", :max_age => "2592000"}
    redirect "/"
  end

  # post /carder/user/check_email_exist
  post "/check_email_exist" do
    user = User.first(email: params[:user][:email])
    res  = { valid: user.nil? }.to_json
    content_type "application/json"
    body res
  end
end
