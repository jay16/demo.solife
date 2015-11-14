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

  get "/examples/local_demos" do
    json_path = app_root_join("config/demo-highcharts.json")
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
