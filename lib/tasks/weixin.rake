#encoding:utf-8
desc "task operation around weixin"
namespace :weixin do
  def lasttime(info, &block)
     bint = Time.now.to_f
     yield
     eint = Time.now.to_f
     printf("%-10s - %s\n", "[%dms]" % ((eint - bint)*1000).to_i, info)
  end

  def puts_response(response)
    puts "code:"
    puts response.code
    puts "body:"
    puts response.body.force_encoding("utf-8")
    puts "message:"
    puts response.message.force_encoding("utf-8")
    puts "headers:"
    puts response.headers.inspect
  end

  desc "get weixin token"
  task :token => :simple do
    weixin_token_file = "%s/tmp/weixin_token" % @options[:app_root_path]
    is_reget_token = true
    if File.exist?(weixin_token_file)
      access_token, expires_at = IO.read(weixin_token_file).strip.split(/,/)
      puts expires_at.to_i
      puts Time.now.to_i
      if expires_at.to_i > Time.now.to_i
        is_reget_token = false 
        puts "get token from tmp file."
        @options[:weixin_access_token] = access_token
        @options[:weixin_expires_at]   = expires_at
      end
    end

    if is_reget_token
      params = []
      { :grant_type => "client_credential",
        :appid      => @options[:weixin_app_id],
        :secret     => @options[:weixin_app_secret]
      }.each_pair do |key, value|
        params.push("%s=%s" % [key, value])
      end
      token_url  = "%s/token?%s" % [@options[:weixin_base_url], params.join("&")]
      hash = JSON.parse(open(token_url).read)
      puts "get token from weixin server."
      @options[:weixin_access_token] = hash[:access_token] || hash["access_token"]
      @options[:weixin_expires_in]   = hash[:expires_in] || hash["expires_in"]
      @options[:weixin_expires_at]   = Time.now.to_i + @options[:weixin_expires_in].to_i
      File.open(weixin_token_file, "w+") do |file|
        file.puts "%s,%s" % [@options[:weixin_access_token], @options[:weixin_expires_at]]
      end
    end
  end
  desc "task operation with weixin user"
  task :user_info => :simple do
    Rake::Task["weixin:token"].invoke
    abort "access_token missing" unless @options[:weixin_access_token]

    Weixiner.all.each do |weixiner|
      next if weixiner.weixiner_info
      params = []
      { :lang         => "zh_CN",
        :openid       => weixiner.uid,
        :access_token => @options[:weixin_access_token]
      }.each_pair do |key, value|
        params.push("%s=%s" % [key, value])
      end
      user_info_url  = "%s/user/info?%s" % [@options[:weixin_base_url], params.join("&")]
      hash = JSON.parse(open(user_info_url).read)
      hash = hash.merge({weixiner_id: weixiner.id})

      puts hash
      weixiner_info = WeixinerInfo.new(hash)
      weixiner_info.save_with_logger
    end
  end

  #require "rest-client"
  require "httparty"
  require "json"
  desc "task create weixin menu."
  task :menu_create => :simple do
    Rake::Task["weixin:menu_delete"].invoke
    abort "access_token missing" unless @options[:weixin_access_token]

    menu_url = "%s/menu/create?access_token=%s" % [@options[:weixin_base_url], @options[:weixin_access_token]]
    menu_params = {
      "button" => [{	
          "type" => "click",
          "name" => "数据统计",
          "key" => "PERSONAL_REPORT"
      }, {
          "type" => "view",
          "name" => "关于",
          "url" => "http://weixin.solife.us/about"
       }]
    }.to_json
    response = HTTParty.post menu_url, body: menu_params, headers: {'ContentType' => 'application/json'} 
    #response = RestClient.post menu_url, menu_params
    puts_response(response)
  end

  desc "task delete weixin menu."
  task :menu_delete => :simple do
    Rake::Task["weixin:token"].invoke
    abort "access_token missing" unless @options[:weixin_access_token]

    menu_url = "%s/menu/delete?access_token=%s" % [@options[:weixin_base_url], @options[:weixin_access_token]]
    response = HTTParty.get menu_url
    puts_response(response)
  end
  desc "task get weixin menu."
  task :menu_get => :simple do
    Rake::Task["weixin:token"].invoke
    abort "access_token missing" unless @options[:weixin_access_token]

    menu_url = "%s/menu/get?access_token=%s" % [@options[:weixin_base_url], @options[:weixin_access_token]]
    response = HTTParty.get menu_url
    puts_response(response)
  end

  task :send_group_message => :simple do
    Rake::Task["weixin:token"].invoke
    abort "access_token missing" unless @options[:weixin_access_token]

    # get report content from consume.solife.us
    api_url = "%s.json?token=%s" % [Settings.consume.api_url, Settings.consume.token]
    response = HTTParty.get api_url
    weixin_message = JSON.parse(response.body)["report"].force_encoding("utf-8")
    raise "group member report is empty!" unless weixin_message
    puts weixin_message

    # get group-id from weixin.qq.com
    groups_url = "%s/groups/get?access_token=%s" % [@options[:weixin_base_url], @options[:weixin_access_token]]
    response = HTTParty.get groups_url
    puts_response(response)
    groups = JSON.parse(response.body.force_encoding("utf-8"))["groups"]
    group_id = groups.find { |group| group["name"].eql?("爱生活") }["id"]

    # send message with weixin.qq.com
    sendall_url = "%s/message/mass/sendall?access_token=%s" % [@options[:weixin_base_url], @options[:weixin_access_token]]
    sendall_params = {
       "filter" => {
          "is_to_all" => false,
          "group_id"  => group_id
       },
       "text" => {
          "content" => weixin_message
       },
        "msgtype" => "text"
    }.to_json
    response = HTTParty.post sendall_url, body: sendall_params, headers: {'ContentType' => 'application/json'} 
    puts_response(response)
  end

  task :preview => :simple do
    Rake::Task["weixin:token"].invoke
    abort "access_token missing" unless @options[:weixin_access_token]

    preview_url = "%s/message/mass/preview?access_token=%s" % [@options[:weixin_base_url], @options[:weixin_access_token]]
    preview_params = {
    "touser" => "oibc6t6XBrs88ewnV-ucmd7yOMYg",
    "text"   => {           
           "content" => "CONTENT"            
           },     
    "msgtype" => "text"
    }.to_json
    response = HTTParty.post preview_url, body: preview_params, headers: {'ContentType' => 'application/json'} 
    puts_response(response)
  end
end
