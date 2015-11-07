#encoding: utf-8
class Demo::HighchartsController < Demo::ApplicationController
  set :views, File.join(ENV["VIEW_PATH"], "demo/highcharts")
  set :layout, "../../layouts/layout".to_sym

  # get /demo/high_chart
  get "/" do
     haml :index, layout: settings.layout
  end

  get "/examples" do
    haml :examples
  end

  get "/examples/*" do
    filename = params[:splat].join.gsub("/","_")
    
    render_url_with_cache(filename)
  end

  def render_url_with_cache(filename)
    filepath = File.join(ENV["APP_ROOT_PATH"], "tmp", filename)

    unless File.exist?(filepath)
      qiniu_url = File.join(Settings.cdn.qiniu.out_link, filename)
      response = HTTParty.get(qiniu_url)
      
      File.open(filepath, "w:utf-8") { |file|
        html = response.body.force_encoding("UTF-8")
        html.sub!('<body>',
                 '<body>
                      <script src="/javascripts/bootstrap.320.min.js" type="text/javascript"></script>
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
end