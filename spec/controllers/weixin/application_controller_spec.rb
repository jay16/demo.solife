#encoding:utf-8
require File.expand_path '../../../spec_helper.rb', __FILE__

describe "WeiXin::ApplictionController" do

  it "Get /weixin should respond a string" do
    get "/weixin"

    expect(last_response.status).to be(200)
    expect(last_response.body).to eq("please point to /weixin/detail-weixin-name")
  end
end
