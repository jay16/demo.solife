#encoding:utf-8
require "date"
require File.expand_path '../../../spec_helper.rb', __FILE__

describe "API::V1" do
  before do
    @user = User.first_or_create({email: "admin@intfocus.com", password: md5_key("D")})
    @params = {email: @user.email, password: @user.password}
  end

  it "should return user info when login successfully" do
    get "/api/v1/user/login.json", @params

    expect(last_response.status).to eq(200)

    hash = JSON.parse(last_response.body)
    expect(hash.keys.sort).to eq(%w[code uid now expired_at notifications].sort)

    uid  = hash["uid"]
    code = hash["code"]
    now  = DateTime.parse(hash["now"]).strftime("%Y/%m/%d %H:%M:%S")
    expired_at    = hash["expired_at"]
    notifications = hash["notifications"]

    expect(uid).to eq(@user.id)
    expect(code).to eq(200)
    expect(now).to  eq(DateTime.now.strftime("%Y/%m/%d %H:%M:%S"))
    expect(expired_at).to eq((@user.expired_at||DateTime.now).strftime("%Y/%m/%d %H:%M:%S"))
  end

  it "should return user info when validate successfully" do
  end

  it "should generate a track url when post submit" do
    params = @params.merge({
        :subject => "hello",
        :to      => "to",
        :tos     => "tos",
        :mid     => md5_key("D")
    })
    post "/api/v1/campaigns.json", params

    expect(last_response.status).to eq(200)
    hash = JSON.parse(last_response.body)
    expect(hash.keys.sort).to eq(%w[code url])

    code = hash["code"]
    url  = hash["url"]
    puts url
  end
  describe "Pre Paid Code" do
    before do
      @params = {
        email:    "admin@intfocus.com",
        password: "123456"
      }
    end

    #it "should generate pre-paid-code with administrator" do
    #  pre_paid_type = "month"
    #  get "/api/v1/%s/pre_paid_code.json" % pre_paid_type, @params

    #  expect(last_response).to be_ok

    #  json = JSON.parse(last_response.body)
    #  pre_paid_code = json["pre_paid_code"] 
    #  pre_paid_type = json["pre_paid_type"]

    #  expect(pre_paid_code.size).to eq(32)
    #  expect(pre_paid_type).to eq("month")
    #end
  end
end
