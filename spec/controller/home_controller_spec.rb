#encoding:utf-8
require File.expand_path '../../spec_helper.rb', __FILE__

describe "HomeController" do

  it "public pages" do
    get "/"
    title = "MailHok"
    expect(last_response.status).to be(200)
    expect(last_response.body).to include(title)

    get "/store"
    expect(last_response.status).to be(200)

    get "/login"
    expect(last_response).to be_redirect
    follow_redirect!
    expect(last_request.url).to eq(redirect_url("/user/login"))

    get "/register"
    expect(last_response).to be_redirect
    follow_redirect!
    expect(last_request.url).to eq(redirect_url("/user/register"))
  end
end
