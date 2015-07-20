﻿#encoding: utf-8 
class UsersController < ApplicationController
  set :views, ENV["VIEW_PATH"] + "/users"
  set :layout, :"../layouts/layout"

  # Get /users
  get "/" do
    redirect to("/users/login") unless current_user
    redirect to("/cpanel") if current_user and current_user.admin?

    @weixiners = Weixiner.all
    @messages  = Message.all
    @phantoms  = Phantom.all

    if @messages.count > 0
      last_modified @messages.first.updated_at
      etag  md5_key(@messages.first.updated_at.to_s)
    end   

    haml :index, layout: settings.layout
  end

  # GET /users/login
  get "/login" do
    @user ||= User.new
    @user.email = request.cookies["_email"]

    haml :login, layout: settings.layout
  end

  # POST /users/login
  post "/login" do
    user = User.first(email: params[:user][:email])
    if user and user.password == md5_key(params[:user][:password])
      response.set_cookie "cookie_user_login_state", {:value=> user.email, :path => "/", :max_age => "2592000"}

      flash[:success] = "登录成功."
      redirect "/account"
    else
      response.set_cookie "cookie_user_login_state", {:value=> "", :path => "/", :max_age => "2592000"}
      response.set_cookie "_email", {:value=> params[:user][:email], :path => "/", :max_age => "2592000"}

      flash[:warning] = "登录失败:" + (user ? "密码错误": "用户不存在")
      redirect "/users/login"
    end
  end

  # GET /users/register
  get "/register" do
    @user ||= User.new

    haml :register, layout: :"../layouts/layout"
  end

  # post /users/register
  post "/register" do
    user_params = params[:user]
    user_params.delete(:confirm_password)
    user_params.delete("confirm_password")
    user_params[:password] = md5_key(user_params[:password])
    user = User.new(user_params)

    if user.save
      response.set_cookie "_email", {:value=> user.email, :path => "/", :max_age => "2592000"}
      flash[:success] = "注册成功，请登录."

      redirect "/users/login"
    else
      msg = ["注册失败:"]
      format_dv_errors(user).each_with_index do |hash, index|
        msg.push("%d. %s" % [index+1, hash.to_a.join(": ")])
      end
      flash[:danger] = msg.join("<br>")
      redirect "/users/register"
    end
  end

  # logout
  # delete /users/logout
  get "/logout" do
    response.set_cookie "cookie_user_login_state", {:value=> "", :path => "/", :max_age => "2592000"}
    redirect "/"
  end

  # post /users/check_email_exist
  post "/check_email_exist" do
    user = User.first(email: params[:user][:email])
    res  = { valid: user.nil? }.to_json
    content_type "application/json"
    body res
  end
end
