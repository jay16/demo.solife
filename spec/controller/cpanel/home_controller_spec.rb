#encoding:utf-8
require File.expand_path "../../../spec_helper.rb", __FILE__

describe "Cpanel::HomeController" do

  it "should redirec to login page when without lgoin" do
    get "/cpanel"
    expect(last_response).to be_redirect
    expect(last_response.status).to be(302)

    follow_redirect!
    expect(last_request.url).to eq(redirect_url("/cpanel/login"))
  end

  it "should show login page when browser /login" do
    get "/cpanel/login"

    expect(last_response).to be_ok
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("登陆")
  end

  it "should login fail with nothing" do
    post "/cpanel/login"

    expect(last_response).to_not be_ok
    expect(last_response.status).to be(401)
  end

  it "should login successfully with correct information" do
    post "/cpanel/login", { :name => "name", :password => "password" }

    expect(last_response).to_not be_ok
    expect(last_response.status).to be(401)
  end

  it "should login successfully with correct information" do
    post "/cpanel/login", { 
      :name     => Settings.login.name, 
      :password => Settings.login.password
    }

    expect(last_response).to be_redirect
    expect(last_response.status).to be(302)

    follow_redirect!
    expect(last_request.url).to eq(redirect_url("/cpanel"))
  end

  it "should record cookie when login successfully" do
    get "/admin"

    expect(last_response).to be_redirect

    follow_redirect!
    expect(last_request.url).to eq(redirect_url("/cpanel"))
    expect(last_response).to be_redirect

    follow_redirect!
    expect(last_request.url).to eq(redirect_url("/cpanel/login"))

    post "/cpanel/login", { 
      :name     => Settings.login.name, 
      :password => Settings.login.password
    }

    expect(last_response).to be_redirect

    follow_redirect!
    expect(last_request.cookies["_login_state"]).to eq(remote_ip)
    expect(last_request.cookies["_before_login_path"]).to eq(redirect_url("/cpanel"))
  end

  it "should show all routes config in this Application" do
    pending "unrealized"
  end
end
