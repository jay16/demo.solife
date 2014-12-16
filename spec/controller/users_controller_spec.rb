#encoding: utf-8
require File.expand_path '../../spec_helper.rb', __FILE__

describe "UsersController" do
  before do
    @params_admin = {
      :email   => "admin@intfocus.com", 
      :password => "123456" 
    }
    @params_normal = {
      :email   => "jay@intfocus.com", 
      :password => "654321" 
    }
  end

  it "should register a administrator" do
    params = @params_admin
    post "/user/register", params

    expect(last_response).to be_redirect
    follow_redirect!
    expect(last_request.url).to eq(redirect_url("/user/login"))

    user = User.first(:email => params[:email])
    expect(user.name).to eq(params[:email].split(/@/)[0])
    expect(user.password).to eq(params[:password])
  end

  it "should login with administrator" do
      params = @params_admin
      post "/user/login", params

      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to eq(redirect_url("/cpanel"))
  end
end
