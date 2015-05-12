#encoding: utf-8 
class Demo::ISearchController < Demo::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/demo"
  set :layout, :"layouts/layout"
  helpers Demo::ISearchHelper

  before do
    @poetries = isearch_poetries
    @content  = isearch_content
    hash_resursion_assign_poetry(@content)
  end

  def hash_resursion_assign_poetry(hash)
    hash[:datas].each do |h|
      poetry = @poetries.at(h[:id].to_i)
      h[:name] = poetry[0]
      h[:desc] = poetry[1]
      hash_resursion_assign_poetry(h) if h[:type].eql?("0")
    end
  end

  # get /demo/isearch
  get "/" do
    #@content = hash_resursion(@content, "3")
    @content = JSON.pretty_generate(@content)
    haml :index, layout: settings.layout
  end
  template :index do
    "%pre= @content"
  end

  # get /demo/isearch/content
  get "/content" do
    id   = (params[:id] || "0").to_s
    type = params[:type] 
    user = params[:user]
    content = Marshal.load(Marshal.dump(@content))

    if id.eql?(content[:id])
      hash = content
    else
      hash = hash_resursion(content, id)
    end

    hash = simple(hash) rescue hash

    respond_with_json hash, 200
  end

  get "/download/:id.zip" do
    filename = "%s.zip" % params[:id]
    poetry = @poetries[params[:id].to_i - 1]

    tmppath  = File.join(ENV["APP_ROOT_PATH"], "tmp")
    scriptpath  = File.join(ENV["APP_ROOT_PATH"], "lib/script/generate_isearch_file.sh")
    filepath = File.join(tmppath, filename)
    

    unless File.exist?(filepath)
      command = <<-SCRIPT 
        cd #{tmppath} \ 
        /bin/sh #{scriptpath} #{params[:id]} "#{poetry[0]}" "#{poetry[1]}"
      SCRIPT
      puts command
      `#{command}`
    end

    send_file(filepath, filename: filename)
  end

  def hash_resursion(hash, id)
    @result_hash = nil
    _hash_resursion(hash, id)
    return @result_hash
  end

  def _hash_resursion(hash, id)
    return unless hash.has_key?(:datas)
    return if @result_hash

    if _hash = hash[:datas].find { |h| h[:id].eql?(id) or h["id"].eql?(id) }
      @result_hash = _hash
    else
      _hash = Marshal.load(Marshal.dump(hash))
      _hash[:datas].each { |h| _hash_resursion(h, id) }
    end
  end

  # params
  #   user:     username or email
  #   password: just password
  #   lang:     app i18 language
  route :get, :post, "/login" do
    username = params[:user] || ""
    password = params[:password] || ""
    applang  = params[:lang] || "zh-CN"
    error = []
    error << "用户名错误" unless username.eql?("root") 
    error << "登陆密码错误" unless password.eql?("admin")

    if error.empty?
      info = { uid: 1, date: Time.now.strftime("%Y-%m-%d %H:%M:%S")}
      code = 1
    else
      info = { error: error.join("\n") }
      code = 0
    end

    hash = { code: code, info: info }
    respond_with_json hash, 200
  end

  private 

  def simple(hash)
    simple_hash = []
    hash[:datas].each do |h|
      h.delete(:datas) if h.has_key?(:datas)
      h[:url] = "http://localhost:3000/demo/isearch/download/%s.zip" % h[:id]
      simple_hash << h
    end if hash.has_key?(:datas)
    return simple_hash
  end
end
