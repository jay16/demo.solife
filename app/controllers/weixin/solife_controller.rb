#encoding: utf-8 
require "lib/utils/weixin/weixin_robot.rb"
require "lib/utils/weixin/solife/reply_robot.rb"
class WeiXin::SOLifeController < WeiXin::ApplicationController
  register Sinatra::WeiXinRobot
  register Sinatra::SOLife::ReplyRobot
  set :views, ENV["VIEW_PATH"] + "/weixin/solife"

  configure do
    set :weixin_token, Settings.weixin.solife.token 
    set :weixin_uri,   "%s/weixin/solife" % Settings.domain
    set :weixin_name,  Settings.weixin.solife.name
    set :weixin_desc,  Settings.weixin.solife.desc
    set :root_path,    ENV["APP_ROOT_PATH"]
    set :nxscae_stock_url,  Settings.nxscae.stock_url
  end

  # weixin authenticate
  # get /weixin/solife
  get "/" do
    params[:echostr].to_s
  end

  # receive message
  # post /weixin/solife
  post "/" do
    return if generate_signature != params[:signature]

    raw_message = request_body(@request_body)
    weixin = message_receiver(raw_message)
    _params = weixin.instance_variables.inject({}) do |hash, var|
      hash.merge!({var.to_s.sub(/@/,"") => weixin.instance_variable_get(var)})
    end
    _params[:from_user_name] = _params.delete("user")
    _params[:to_user_name]   = _params.delete("robot")

    weixiner = Weixiner.first_or_create({uid: _params[:from_user_name]}, {name: "solife"})
    weixiner.update(name: "solife") unless weixiner.name.eql?("solife")
    message = weixiner.messages.create(_params)

    reply = ["消息创建成功.", ""]
    Timeout::timeout(4) do # weixin limit 5s callback
      reply << message.reply

      clear_reply, reply_content = reply_robot(message)
      reply.clear if clear_reply
      reply << reply_content unless reply_content.strip.empty?

      message.update(response: reply.join("\n"))
    end

    weixin.sender(msg_type: "text") do |msg|
      msg.content = truncate_text(message.response)
      msg.to_xml
    end
  end

  def truncate_text(text)
    return "服务器出现bug^_^" unless text
    return text if text.length <= 1000

    text[0...1000] + "\n..."
  end
end
