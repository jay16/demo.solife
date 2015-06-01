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
  require "cgi"
  # get /demo/isearch/reorganize
  get "/reorganize" do
    content, file_index = [], 100

    tmp_path = File.join(ENV['APP_ROOT_PATH'], "tmp")
    tmp_bash = "tmp.sh"
    @poetries.each_slice(@poetries.count/3) do |array|
      zip_path = File.join(tmp_path, "#{file_index}.zip")

      desc = {
        name: "文件#{file_index} - 内容重组",
        type: "1",
        id: file_index.to_s,
        desc: "描述文件 - #{file_index}",
        url: zip_url(file_index)
      }
      unless File.exist?(zip_path)
        command = <<-BASH
          #!/bin/bash

          font_url="http://solife-code.u.qiniudn.com/STXINGKA.ttf"
          font_name=${font_url##*/}

          test -f ${font_name} || wget ${font_url}
          test -d ${file_index} || mkdir ${file_index}
        BASH
        page_order = []
        array.each_with_index do |poetry, page_index|
           page_order << "#{file_index}_#{page_index}"
           command << %Q{\nconvert -background white -fill blue -font ${font_name} -pointsize 72 label:"#{poetry.join('\n')}" #{file_index}/#{file_index}_#{page_index}.gif}
           command << <<-BASH
             \necho " 
             <html>
              <body>
                <img src='./#{file_index}_#{page_index}.gif'>
              </body>
             </html>" > #{file_index}/#{file_index}_#{page_index}.html
           BASH
        end
        desc[:order] = page_order
        command << <<-BASH
          echo '#{desc.to_json}' > #{file_index}/desc.json

          test -f #{file_index}.zip && rm #{file_index}.zip
          zip -r #{file_index}.zip #{file_index}/
        BASH
        
        File.open(File.join(tmp_path, tmp_bash), "w+") do |file|
          file.write(command.gsub(/^(\s+)/, ""))
        end
        `cd #{tmp_path} && /bin/sh #{tmp_bash}`
      end
      content << desc
      file_index += 1
    end

    respond_with_json content, 200
    #@show = CGI.escapeHTML(@show)
    #haml :reorganize, layout: settings.layout
  end
  template :reorganize do
    "%pre= @show"
  end

  # get /demo/isearch/offline
  get "/offline" do
    datas = (1..300).map do |i|
      poetry = @poetries.at(i % @poetries.count)
      { id: i, type: 1, name: poetry[0], desc: poetry[1], tags: "", page_count: 1, zip_url: zip_url(i) }
    end

    respond_with_json datas, 200
  end

  # get /demo/isearch/download/1.zip
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


  # get /demo/isearch/login
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

  # get /demo/isearch/notificiations
  get "/notifications" do
    lambda_date_format = lambda do |date| 
      if date and date.respond_to?(:strftime)
        date.strftime("%Y/%m/%d %H:%M:%S")
      else
        # occur_date 随机生成，1/3公告为预告
        if rand(100) % 3 == 0
          date = Time.now + 60*60*24*rand(10)
          date.strftime("%Y/%m/%d")
        end
      end
    end
    notifications = (1..30).map do |index|
      content = %Q{公告内容 #{rand(1000) % index == 3 ? @poetries.sample.flatten.join("\n") : index}}
      { title: "公告通知 %d" % index, msg: content, created_date: lambda_date_format.call(Time.now), occur_date: lambda_date_format.call(nil), type: "isearch" }
    end

    respond_with_json notifications, 200
  end


  private 

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
  
  def zip_url(id)
    local_url = "http://localhost:3000/demo/isearch/download/%s.zip" % id;
    vps_url   = "http://demo.solife.us/demo/isearch/download/%s.zip" % id

    case ENV["PLATFORM_OS"]
    when "darwin" then local_url
    when "linux"  then vps_url
    else local_url 
    end
  end

  def simple(hash)
    simple_hash = []
    hash[:datas].each do |h|
      h.delete(:datas) if h.has_key?(:datas)
      h[:url] = zip_url(h[:id])
      simple_hash << h
    end if hash.has_key?(:datas)
    return simple_hash
  end
end
