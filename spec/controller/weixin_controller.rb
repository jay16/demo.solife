#encoding:utf-8
require File.expand_path '../../spec_helper.rb', __FILE__
require File.expand_path '../../weixin_helper.rb', __FILE__

describe "WeixinController" do

  it "weixin server test with echostr params" do
    echostr = Weixin::Utils.rand_secret
    get Weixin::Utils.base_url("/weixin", Settings.weixin.token, {echostr: echostr})

    expect(last_response.status).to be(200)
    expect(last_response.body).to eq(echostr)
  end

  describe "weixin server turn it to here when user send message" do
    require "lib/utils/weixin_robot.rb"
    include Sinatra::WeiXinRobot::RobotHelpers

    def text_message_rspec(raw_message, expect_message_regexp)
      message = Weixin::Utils.message_builder(raw_message)

      post Weixin::Utils.base_url("/weixin", Settings.weixin.token, {}), message, content_type: 'text/xml; charset=utf-8'

      receiver = message_receiver(last_response.body)
      expect(receiver.text?).to be(true)
      expect(receiver.content).to match(expect_message_regexp)
    end

    it "should respond fail when user email not exist" do
      text_message_rspec("无关键字测试", /^消息创建成功/)
    end

    it "should trigger callback when /^账户绑定/" do
      text_message_rspec("帐户绑定 use-not-exist@email.com", /帐户绑定失败/)
      text_message_rspec("账户绑定 use-not-exist@email.com", /帐户绑定失败/)

      if User.count
      	eamil = User.first.email
        text_message_rspec("帐户绑定 #{eamil}", /帐户绑定: 成功/)
      end
    end

    it "should trigger callback when /^消费记录/" do
      #text_message_rspec("消费记录 123元", /执行\d+次回调函数/)
      pending "sync db file"
    end

    it "should respond with nxscae stock info when /^nxscae 铜章/" do
    	keywords = %w() 
        text_message_rspec("nxscae #{keywords.join(' ')}", /搜索到\s+\d+\s+条结果/)
    	keywords = %w(铜章) 
        text_message_rspec("nxscae #{keywords.join(' ')}", /搜索到\s+\d+\s+条结果/)
    end
  end
end
