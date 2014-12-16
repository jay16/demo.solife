#encoding: utf-8 
class HomeController < ApplicationController
  set :views, ENV["VIEW_PATH"] + "/home"

  # root page
  get "/" do
    redirect "/carder" if current_user

    haml :index, layout: :"../layouts/layout"
  end

  # redirect to cpanel
  get "/admin" do
    redirect "/carder"
  end

  # weixin auto response
  # download vcf file
  get "/vcf/*.*" do |base_name, ext|
    vcf_name = [base_name, ext].join(".") 
    vcf_path = File.join(ENV["APP_ROOT_PATH"], "public/vcfs", vcf_name)
    send_file(vcf_path, :filename => vcf_name)
  end

  # redirect
  # login
  get "/login" do
    redirect "/carder/user/login"
  end
  # register
  get "/register" do
    redirect "/carder/user/register"
  end
end
