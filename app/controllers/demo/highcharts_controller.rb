#encoding: utf-8
class Demo::HighchartsController < Demo::ApplicationController
  set :views, File.join(ENV["VIEW_PATH"], "demo/highcharts")
  set :layout, "../../layouts/layout".to_sym

  # get /demo/high_chart
  get "/" do
     haml :index, layout: settings.layout
  end

  get "/examples" do
    render_url_with_cache("index.htm")
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
        file.puts(response.body.force_encoding("UTF-8"))
      }
      response.body
    end

    IO.read(filepath)
  end
end