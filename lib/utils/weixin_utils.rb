#encoding:utf-8
require "settingslogic"
require "httparty"
require "open-uri"
require "json"

module WeixinUtils
  module UtilsMethods
    def base_on_root_path(path)
      if @options.has_key?(:app_root_path)
        File.join(@options[:app_root_path], path)
      else
        raise "[dangerous] @options missing key - :app_root_path"
      end
    end

    def generate_token 
      weixin_token_file = base_on_root_path("tmp/weixin_token")
      is_token_expired = true
      if File.exist?(weixin_token_file)
        access_token, expires_at = IO.read(weixin_token_file).strip.split(/,/)
        if expires_at.to_i > Time.now.to_i
          is_token_expired = false 
          @options[:weixin_access_token] = access_token
          @options[:weixin_expires_at]   = expires_at
        end
      end

      if is_token_expired
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

    def generate_weixiner_info(weixiners)
      abort "access_token missing" unless @options[:weixin_access_token]

      weixiners.each do |weixiner|
        next if weixiner.weixiner_info
        params = []
        { :lang         => "zh_CN",
          :openid       => weixiner.uid,
          :access_token => @options[:weixin_access_token]
        }.each_pair do |key, value|
          params.push("%s=%s" % [key, value])
        end
        user_info_url  = "%s/user/info?%s" % [@options[:weixin_base_url], params.join("&")]
        hash = ::JSON.parse(open(user_info_url).read)
        puts "*"*10
        puts weixiner.weixiner_info.class
        puts "*"*10
        weixiner_info = ::WeixinerInfo.new(hash)
        weixiner_info.save_with_logger
        weixiner.weixiner_info = weixiner_info
        weixiner.save_with_logger
      end
    end

    def menu_create
      abort "access_token missing" unless @options[:weixin_access_token]

      menu_url = "%s/menu/create?access_token=%s" % [@options[:weixin_base_url], @options[:weixin_access_token]]
      menu_params = {
        "button" => [{	
            "type" => "click",
            "name" => "数据统计",
            "key" => "PERSONAL_REPORT"
        }, {
            "type" => "view",
            "name" => "关于小6",
            "url" => "http://xiao6yuji.com/about"
         }]
      }.to_json
      HTTParty.post menu_url, body: menu_params, headers: {'ContentType' => 'application/json'} 
    end

    def menu_delete
      abort "access_token missing" unless @options[:weixin_access_token]

      menu_url = "%s/menu/delete?access_token=%s" % [@options[:weixin_base_url], @options[:weixin_access_token]]
      HTTParty.get menu_url
    end

    def menu_get
      abort "access_token missing" unless @options[:weixin_access_token]

      menu_url = "%s/menu/get?access_token=%s" % [@options[:weixin_base_url], @options[:weixin_access_token]]
      HTTParty.get menu_url
    end
  end

  class Operation
    include WeixinUtils::UtilsMethods

    def initialize
      @options ||= {}
      @options[:app_root_path] = ENV["APP_ROOT_PATH"]
      unless defined?(::Settings)
        load base_on_root_path("app/models/settings.rb")
      end


      @options[:weixin_app_id]     = ::Settings.weixin.app_id
      @options[:weixin_app_secret] = ::Settings.weixin.app_secret
      @options[:weixin_base_url]   = "https://api.weixin.qq.com/cgi-bin"
      generate_token
    end

    def self.generate_weixiner_info(weixiners)
      operation = new
      operation.generate_weixiner_info(weixiners)
    end
  end
end
