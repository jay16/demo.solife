#encoding: utf-8
class Demo::HighchartsController < Demo::ApplicationController
  set :views, File.join(ENV["VIEW_PATH"], "demo/highcharts")
  set :layout, "../../layouts/layout".to_sym

  # get /demo/high_chart
  get "/" do
     haml :index, layout: settings.layout
  end

  get "/examples" do
    render_url_as_template("index.htm")
  end
  get "/examples/*" do
    filename = params[:splat].join.gsub("/","_")
    render_url_as_template(filename)
  end

  def render_url_as_template(filename)
    qiniu_url = File.join(Settings.cdn.qiniu.out_link, filename)

    response = HTTParty.get(qiniu_url)
    response.body
  end
end