#encoding:utf-8
require File.expand_path '../../../spec_helper.rb', __FILE__
require File.expand_path '../weixin_spec_utils.rb', __FILE__

describe "WeiXin::SOLifeController" do

  it "weixin server test with echostr params" do
    echostr = Weixin::Spec::Utils.rand_secret
    get Weixin::Spec::Utils.base_url("/weixin/solife", Settings.weixin.solife.token, {echostr: echostr})

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

    it "should respond fail when user email not exist" do
      weixin_text_message_test("无关键字测试", /^消息创建成功/)
    end

    it "should trigger callback when /^账户绑定/" do
      weixin_text_message_test("帐户绑定 use-not-exist@email.com", /帐户绑定失败/)

      if user = User.first
      	eamil = user.email
        weixin_text_message_test("帐户绑定 #{eamil}", /帐户绑定: 成功/)
      end
    end

    it "should trigger callback when /^消费记录/" do
      #text_message_rspec("消费记录 123元", /执行\d+次回调函数/)
      pending "sync db file"
    end

    it "should respond with nxscae stock info when /^nxscae 铜章/\n NOTE:close VPN!" do
    	keywords = %w() 
      weixin_text_message_test("nxscae #{keywords.join(' ')}", /搜索到\s+\d+\s+条结果/)
    	keywords = %w(铜章) 
      weixin_text_message_test("nxscae #{keywords.join(' ')}", /搜索到\s+\d+\s+条结果/)
    	keywords = %w(忽略首字段大小写) 
      weixin_text_message_test("Nxscae #{keywords.join(' ')}", /搜索到 0 条结果/)
    end
  end
end
