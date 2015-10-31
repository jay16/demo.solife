#encoding: utf-8 
class Demo::HomeController < Demo::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/demo/home"
  set :layout, :"../../layouts/layout"
  
  before do
    set_seo_meta("实验室", "实验室, solife", "segment of jay's life.")
  end

  # /demo
  get "/" do
    json_path = File.join(ENV["APP_ROOT_PATH"], "config/demo-index.json")

    @demo_items = JSON.parse(IO.read(json_path))

    haml :index#, layout: settings.layout
  end

  get "/upload" do
    haml :upload, layout: settings.layout
  end

  post "/upload" do
    # puts params
    # respond_with_json params
    begin
      puts params
      unless params[:file] &&  
           (tempfile = params[:file][:tempfile]) &&  
           (filename = params[:file][:filename]) 
        
        hash = { "error" => "参数不足" }
        respond_with_json hash
        return
      end  

      filepath = File.join(ENV["APP_ROOT_PATH"], "tmp", filename)
      File.open(filepath, 'wb') {|f| f.write tempfile.read }  

      if File.exist?(filepath)
        hash = { "status" => "上传成功", "FileSize" => File.size(filepath).to_s }
      else 
        hash = { "error" => "上传失败" } 
      end
      hash.merge!(params)
      respond_with_json hash
    rescue => e
      puts e.message
    end
  end
end
