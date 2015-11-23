#encoding: utf-8
class Demo::HighchartsController < Demo::ApplicationController
  set :views, File.join(ENV["VIEW_PATH"], "demo/highcharts")
  set :layout, "../../layouts/layout".to_sym

  # get /demo/highcharts
  get "/" do
    cache_with_mtime("index")

    haml :index, layout: settings.layout
  end

  get "/examples" do
    cache_with_mtime("examples")

    haml :examples
  end

  get "/:filename/download" do
    zip_path = app_root_join("tmp/#{params[:filename]}")

    send_file(zip_path, filename: params[:filename])
  end

  get "/examples/local_demos" do
    json_path = app_root_join("tmp/demo-highcharts.json")
    hash = JSON.parse(IO.read(json_path))

    respond_with_json hash, 200
  end

  get "/examples/*" do
    filename = params[:splat].join.gsub("/","_")
    if filename.eql?("setting")
      haml filename.to_sym
    else
      render_url_with_cache(filename)
    end
  end

  post "/upload" do
    notice = "上传成功"
    begin
      if params[:file] &&  
           (tempfile = params[:file][:tempfile]) &&  
           (filename = params[:file][:filename]) 
        
        filepath = app_root_join("tmp/" + filename)
        File.open(filepath, 'wb') {|f| f.write tempfile.read }  

        if File.exist?(filepath)
          filesize = File.size(filepath).to_s

          json_path = app_root_join("tmp/demo-highcharts.json")
          data_list = File.exist?(json_path) ? JSON.parse(IO.read(json_path)) : []
          hash = data_list.find { |demo| demo["name"] == filename }
          is_new = hash == nil
          hash ||= {}
          hash["name"] = filename[0..-5]
          hash["link"] =  "%s/demo/highcharts/%s/download" % [request.url.sub(request.path, ""), filename]
          hash["filesize"] = filesize
          hash["timestamp"] = Time.now.utc

          data_list.push(hash) if is_new
          File.open(json_path, 'wb') {|f| f.write data_list.to_json }

          notice = "%s, 文件大小: %s" % [notice, human_filesize(filepath)]
        else 
          notice = "上传失败"
        end
      else
          notice = "参数不足"
      end  
      flash[:success] = notice
    rescue => e
      flash[:danger] = e.message
    end

    redirect to("/")
  end


  def render_url_with_cache(filename)
    filepath = app_root_join("tmp/" + filename)

    unless File.exist?(filepath)
      qiniu_url = File.join(Settings.cdn.qiniu.out_link, filename)
      response = HTTParty.get(qiniu_url)
      
      File.open(filepath, "w:utf-8") { |file|
        html = response.body.force_encoding("UTF-8")
        html.sub!('<body>',
                 '<body>
                      <script src="/javascripts/bootstrap.min.js" type="text/javascript"></script>
                      <link href="/stylesheets/bootstrap.320.min.css" media="screen" rel="stylesheet" type="text/css">

                      <div class="container">
                          <div class="row">
                            <ul class="pager">
                              <li class="previous"><a href="/demo/highcharts/examples"><span aria-hidden="true">&larr;</span> Back</a></li>
                            </ul>')
        html.sub!('</body>','</div></div></body>')
        file.puts(html)
      }
    end

    IO.read(filepath)
  end

  def cache_with_mtime(pagename)
    cache_with_custom_defined(File.join(settings.views, "#{pagename}.haml"))
  end
end
