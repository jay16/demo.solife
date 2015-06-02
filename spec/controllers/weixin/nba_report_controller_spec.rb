#encoding:utf-8
require File.expand_path '../../../spec_helper.rb', __FILE__
require File.expand_path '../weixin_spec_utils.rb', __FILE__

describe "WeiXin::NBAReportController" do

  it "weixin server test with echostr params" do
    echostr = Weixin::Spec::Utils.rand_secret
    get Weixin::Spec::Utils.base_url("/weixin/nba_report", Settings.weixin.nba_report.token, {echostr: echostr})

    expect(last_response.status).to be(200)
    expect(last_response.body).to eq(echostr)
  end

  describe "deal with weixin event when subscribe or not" do
    it "respond welcome text when subscribe" do
      pending "respond welcome text when subscribe"
    end

    it "respond thanks text when unsubscribe" do
      pending "respond thanks text when unsubscribe"
    end
  end

  describe "weixin server turn it to here when user send text message" do
    require "lib/utils/weixin/weixin_robot.rb"
    include Sinatra::WeiXinRobot::RobotHelpers

    it "should respond with '内测中...'" do
      weixin_text_message_test("你们现在做什么呢", /^内测中/)
    end

  end
end
