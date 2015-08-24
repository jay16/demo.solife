#encoding: utf-8
module Demo
  class ApplicationController < ApplicationController
    helpers Demo::ApplicationHelper

    before do
      set_seo_meta("实验室", "SOLife,实验室", "segment of jay's life!")
    end

    get "/:file.pdf" do
      send_file File.join(ENV["APP_ROOT_PATH"], "app/views/demo/pdf_js/iSearch.pdf")
    end

    post "/" do
      respond_with_json params
    end

    post "/:upload_file_name" do
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
        hash = { "上传成功" => File.size(filepath).to_s }
      else 
        hash = { "error" => "上传失败" } 
      end
        
      respond_with_json hash
    end
  end
end
