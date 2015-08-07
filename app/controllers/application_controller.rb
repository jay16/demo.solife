#encoding: utf-8
require "json"
require 'digest/md5'
require "sinatra/decompile"
require 'sinatra/advanced_routes'
require "sinatra/multi_route"
class ApplicationController < Sinatra::Base
  register Sinatra::Reloader if development? or test?
  register Sinatra::Flash
  register Sinatra::Decompile
  register Sinatra::Logger
  register SinatraMore::MarkupPlugin
  register Sinatra::MultiRoute
  # register Sinatra::AdvancedRoutes
  # register Sinatra::Auth
  
  # helpers
  helpers ApplicationHelper
  helpers HomeHelper

  # css/js/view配置文档
  use ImageHandler
  use SassHandler
  use CoffeeHandler
  use AssetHandler

  set :root, ENV["APP_ROOT_PATH"]
  enable :sessions, :logging, :dump_errors, :raise_errors, :static, :method_override

  before do
    @request_body = request_body
    request_hash = JSON.parse(@request_body) rescue {}
    @params = params.merge(request_hash)
    @params = @params.merge({ip: request.ip, browser: request.user_agent})

    print_format_logger

    set_seo_meta("点滴记录", "SOLife,个人实验室", "segment of jay's life!")
  end


  # global functions list
  def run_shell(cmd)
    IO.popen(cmd) { |stdout| stdout.reject(&:empty?) }
      .unshift($?.exitstatus.zero?)
  end 

  # global function
  def uuid(str)
    str += Time.now.to_f.to_s
    md5_key(str)
  end

  def md5_key(str)
    Digest::MD5.hexdigest(str)
  end

  def sample_3_alpha
    (('a'..'z').to_a + ('A'..'Z').to_a).sample(3).join
  end

  def regexp_ppc_order
    @regexp_ppc_order ||= Regexp.new(Settings.regexp.order)
  end

  def regexp_ppc_order_item
    @regexp_ppc_order_item ||= Regexp.new(Settings.regexp.order_item)
  end

  def current_user
    @current_user ||= User.first(email: request.cookies["cookie_user_login_state"] || "")
  end
  # action_logger
  # current_user
  include Utils::ActionLogger

  # filter
  def authenticate! 
    if request.cookies["cookie_user_login_state"].to_s.strip.empty?
      # 记录登陆前的path，登陆成功后返回至此path
      response.set_cookie "cookie_before_login_path", {:value=> request.url, :path => "/", :max_age => "2592000"}

      flash[:notice] = "继续操作前请登录."
      redirect "/users/login", 302
    end
  end

  # format gem#dm-validations errors info
  def format_dv_errors(model)
    errors = []
    model.errors.each_pair do |key, value|
      errors.push({ key => value })
    end
    return errors
  end

  def print_format_logger
    request_info = @request_body.empty? ? %Q{Request:\n #{@request_body }} : ""
    log_info = (<<-EOF).gsub(/^ {6}/, '')
      #{request.request_method} #{request.path} for #{request.ip} at #{Time.now.to_s}
      Parameters:\n #{@params.to_s}
      #{request_info}
    EOF
    puts log_info
    logger.info log_info
  end

  # 遍历params寻找二级hash
  def grep_params_model(hash)
    models  = %w[user package order track campaign]
    model = hash.inject([]) do |sum, _hash|
      key, value = _hash
      sum.push(key) if key and value.is_a?(Hash)
      sum
    end.uniq.first
    if model and models.include?(model)
      return model
    end
  end

  def request_body(body = request.body)
    case body
    when StringIO then body.string
    when Tempfile,
      # gem#passenger is ugly!
      #     it will change the structure of REQUEST
      #     detail at: https://github.com/phusion/passenger/blob/master/lib/phusion_passenger/utils/tee_input.rb
      (defined?(PhusionPassenger) and PhusionPassenger::Utils::TeeInput),
      # gem#unicorn
      #     it also change the strtucture of REQUEST
      (defined?(Unicorn) and Unicorn::TeeInput),
      (defined?(Rack) and Rack::Lint::InputWrapper)

      body.read if body.respond_to?(:read)
    else
      body.to_str
    end.to_s.strip
  rescue => e
    e.message
  end

  def print_query_sql(collection)
    #logger.info %Q(\nSQL:\n %s\n) % DataMapper.repository.adapter.send(:select_statement,collection.query).join(" ")
  end

  def respond_with_json hash, code = nil
    content_type "application/json;charset=utf-8"
    body   hash.to_json
    status code || 200
  end

  def set_seo_meta(title = '',meta_keywords = '', meta_description = '')
    @page_title = title
    @meta_keywords = meta_keywords
    @meta_description = meta_description
  end

  # 404 page
  not_found do
    haml :"shared/not_found", layout: :"layouts/layout", views: ENV["VIEW_PATH"]
  end
end
