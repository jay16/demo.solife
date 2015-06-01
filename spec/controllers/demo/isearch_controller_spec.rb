#encoding:utf-8
require File.expand_path "../../../spec_helper.rb", __FILE__

describe "Demo::ISearchController" do

  it "isearch index page show content json" do
  	get "/demo/isearch"
  	expect(last_response.status).to eq(200)
  end

  it "获取目录的 json array" do
  	get "/demo/isearch/content", {id: "0", type: "0", user: "0"}

  	expect(last_response.status).to eq(200)
  	expect(JSON.parse(last_response.body).class).to eq(Array)
  end

  it "模拟内容重组而特别处理的文件压缩档" do
  	get "/demo/isearch/reorganize"

  	expect(last_response.status).to eq(200)
  	expect(JSON.parse(last_response.body).class).to eq(Array)
  end

  it "下载服务器信息 for iPad离线搜索" do
  	get "/demo/isearch/offline"

  	expect(last_response.status).to eq(200)
  	expect(JSON.parse(last_response.body).class).to eq(Array)
  end

  it "文档下载" do
  	zip_file = "1.zip"
  	get "/demo/isearch/download/#{zip_file}"
  	file_path = File.join(ENV["APP_ROOT_PATH"], "tmp", zip_file)
  	command = <<-BASH
  		if [[ "$(uname -s)" == "Darwin" ]]; then 
  			md5 -q #{file_path}; 
  		else 
  			md5sum #{file_path} | awk '{ print $1 }'
  		fi
  	BASH
  	md5_value = `#{command}`.strip

  	expect(last_response.status).to eq(200)
  	expect(Digest::MD5.hexdigest(last_response.body)).to eq(md5_value)
  end

  it "登陆" do
  	get "/demo/isearch/login", {user: "root", password: "admin", lang: "zh-CN"}

  	expect(last_response.status).to eq(200)
  	expect(JSON.parse(last_response.body)["code"]).to eq(1)


  	get "/demo/isearch/login", {user: "not-root", password: "admin", lang: "zh-CN"}

  	expect(last_response.status).to eq(200)
  	expect(JSON.parse(last_response.body)["code"]).to eq(0)
  end

  it "公告通知" do
  	get "/demo/isearch/notifications"

  	expect(last_response.status).to eq(200)
  	expect(JSON.parse(last_response.body).class).to eq(Array)
  end
end
