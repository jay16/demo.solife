#encoding: utf-8 
class Demo::ISearchController < Demo::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/demo"
  set :layout, :"layouts/layout"

  before do
    @content = {
      :id   => "0",
      :type => "dir",
      :desc => "",
      :name => "dir_0",
      :datas => [
        {
        :id   => "1",
        :name => "dir_1",
        :type => "dir",
        :desc => "dir_1",
        :datas => [
          { :id   => "3",
            :name => "dir_3",
            :type => "dir",
            :desc => "dir_3",
            :datas => [ 
              { :id => "4", name: "file_4", :type => "file", desc: "file-4", url: "url" },
              { :id => "5", name: "file_5", :type => "file", desc: "file-5", url: "url" },
              { :id => "6", name: "file_6", :type => "file", desc: "file-6", url: "url" },
              { :id => "7", name: "file_7", :type => "file", desc: "file-7", url: "url" },
              { :id => "8", name: "file_8", :type => "file", desc: "file-8", url: "url" }
            ]
          }]
        },
        {
          :id   => "9",
          :name => "file_9",
          :type => "file",
          :desc => "",
          :url  => ""
        },
        {
          :id   => "10",
          :name => "file_10",
          :type => "file",
          :desc => "",
          :url  => ""
        },
        {
          :id   => "11",
          :name => "file_11",
          :type => "file",
          :desc => "",
          :url  => ""
        },
        {
          :id   => "12",
          :name => "file_12",
          :type => "file",
          :desc => "",
          :url  => ""
        }
      ]
    }
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
    id   = params[:id] || "0"
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
      simple_hash << h
    end if hash.has_key?(:datas)
    return simple_hash
  end
end
