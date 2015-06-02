#encoding: utf-8
require "lib/utils/weixin/weixin_robot.rb"
require "lib/utils/weixin/nba_report/reply_robot.rb"
class WeiXin::NBAReportController < WeiXin::ApplicationController
  register Sinatra::WeiXinRobot
  register Sinatra::NBAReport::ReplyRobot
  set :views, ENV["VIEW_PATH"] + "/weixin/nba_report"

  configure do
    set :weixin_token, Settings.weixin.nba_report.token 
    set :weixin_uri,   "%s/weixin/nba_report" % Settings.domain
    set :weixin_name,  Settings.weixin.nba_report.name
    set :weixin_desc,  Settings.weixin.nba_report.desc
    set :root_path,    ENV["APP_ROOT_PATH"]
  end

  # weixin authenticate
  # get /weixin/nba_report
  get "/" do
    params[:echostr].to_s
  end

  # receive message
  # post /weixin/nba_report
  post "/" do
    return if generate_signature != params[:signature]

    raw_message = request_body(@request_body)
    weixin = message_receiver(raw_message)
    _params = weixin.instance_variables.inject({}) do |hash, var|
      hash.merge!({var.to_s.sub(/@/,"") => weixin.instance_variable_get(var)})
    end
    _params[:from_user_name] = _params.delete("user")
    _params[:to_user_name]   = _params.delete("robot")

    weixiner = Weixiner.first_or_create({uid: _params[:from_user_name]}, {name: "nba_report"})
    weixiner.update(name: "nba_report") unless weixiner.name.eql?("nba_report")
    message = weixiner.messages.create(_params)

    Timeout::timeout(4) do # weixin limit 5s callback
      reply_content = reply_robot(message)
      message.update(response: reply_content)
    end

    weixin.sender(msg_type: "text") do |msg|
      msg.content = message.response
      msg.to_xml
    end
  end
end
