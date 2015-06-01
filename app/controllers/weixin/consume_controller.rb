#encoding: utf-8 
require "lib/utils/weixin/weixin_robot.rb"
require "lib/utils/weixin/consume/reply_robot.rb"
class WeiXin::ConsumeController < WeiXin::ApplicationController
  register Sinatra::WeiXinRobot
  register Sinatra::ReplyRobot
  set :views, ENV["VIEW_PATH"] + "/weixin/consume"

  configure do
    set :weixin_token, Settings.weixin.token 
    set :weixin_uri,   "%s/weixin" % Settings.domain
    set :weixin_name,  Settings.weixin.name
    set :weixin_desc,  Settings.weixin.desc
    set :nxscae_stock_url,  Settings.nxscae.stock_url
    set :root_path,    ENV["APP_ROOT_PATH"]
  end

  # weixin authenticate
  # get /weixin
  get "/" do
    params[:echostr].to_s
  end

  # receive message
  post "/" do
    return if generate_signature != params[:signature]

    raw_message = request_body(@request_body)
    weixin = message_receiver(raw_message)
    _params = weixin.instance_variables.inject({}) do |hash, var|
      hash.merge!({var.to_s.sub(/@/,"") => weixin.instance_variable_get(var)})
    end
    _params[:from_user_name] = _params.delete("user")
    _params[:to_user_name]   = _params.delete("robot")

    weixiner = Weixiner.first_or_create(uid: _params[:from_user_name])
    weixiner = Weixiner.first(id: 1)
    message = weixiner.messages.new(_params)
    message.save_with_logger

    reply = ["消息创建成功.", ""]
    Timeout::timeout(4) do # weixin limit 5s callback
      reply << message.reply

      clear_reply, reply_content = reply_robot(message)
      reply.clear if clear_reply
      reply << reply_content unless reply_content.strip.empty?

      message.update(response: reply.join("\n"))
    end

    weixin.sender(msg_type: "text") do |msg|
      #msg.content = weixiner.personal_report
      msg.content = message.response
      msg.to_xml
    end
  end
end
