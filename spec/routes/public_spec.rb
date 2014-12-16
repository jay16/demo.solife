#encoding:utf-8
require File.expand_path '../../spec_helper.rb', __FILE__

describe "PublicRoute" do

  it "should show prehome page" do
    get "/"
    title = "我喝茶 | 在路上"
    expect(response.status).to be(200)
    expect(response.body).to include(title)
  end

  it "should show home page" do
    get "/home"
    expect(response.status).to be(200)
  end

  it "should show shop cart page" do
    get "/cart"
    expect(response.status).to be(200)
  end
end
