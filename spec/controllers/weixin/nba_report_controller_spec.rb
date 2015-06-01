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

    def text_message_rspec(raw_message, expect_message_regexp)
      message = Weixin::Spec::Utils.message_builder(raw_message)

      post Weixin::Spec::Utils.base_url("/weixin/nba_report", Settings.weixin.nba_report.token, {}), message, content_type: 'text/xml; charset=utf-8'

      receiver = message_receiver(last_response.body)
      expect(receiver.text?).to be(true)
      expect(receiver.content).to match(expect_message_regexp)
    end

    it "should respond with '内测中...'" do
      text_message_rspec("你们现在做什么呢", /^内测中/)
    end

  end
end
