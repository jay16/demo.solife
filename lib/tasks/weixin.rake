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
    puts response.body
    puts "message:"
    puts response.message
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

  task :sendall => :simple do
    Rake::Task["weixin:token"].invoke
    abort "access_token missing" unless @options[:weixin_access_token]

    change_logs_path = File.join(ENV["APP_ROOT_PATH"], "public/change_logs")
    content = ""
    Dir.entries(change_logs_path).grep(/\.cl$/) do |file|
      cl_id = file.sub(".cl","")
      change_log = ChangeLog.first(id: cl_id.to_i)
      next unless change_log.publish
      content << "\n标题: %s" % change_log.title
      content << "\n内容: %s" % change_log.content
      content << "\n标签: %s" % change_log.tag
      content << "\n"
    end
    unless content.strip.empty?
      sendall_url = "%s/message/mass/sendall?access_token=%s" % [@options[:weixin_base_url], @options[:weixin_access_token]]
      sendall_params = {
         "filter" => {
            "is_to_all" => true
         },
         "text" => {
            "content" => content
         },
          "msgtype" => "text"
      }.to_json
      response = HTTParty.post sendall_url, body: sendall_params, headers: {'ContentType' => 'application/json'} 
      puts content
      puts_response(response)
      system("rm -f %s/*.cl" % File.join(ENV["APP_ROOT_PATH"], "public/change_logs"))
    end
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
