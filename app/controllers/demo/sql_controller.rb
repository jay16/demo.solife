#encoding: utf-8 
require "%s/lib/utils/demo/sql_parser.rb" % ENV["APP_ROOT_PATH"]
class Demo::SqlController < Demo::ApplicationController
  set :views, File.join(ENV["VIEW_PATH"], "demo/sql_parser")
  set :layout, :"../../layouts/layout"

  before do
    set_seo_meta("SQL Insert分解器", "sql,insrt,分解,字段过多,不便于阅读", "sql insert语句字段过多时，不便于阅读，分解为字段名与赋值一一对应")
  end

  # get /demo/sql
  get "/" do
    haml :index, layout: settings.layout
  end

  # post /demo/sql/parse/insert_with_values
  post "/parse/insert_with_values" do
    begin
      @output = Utils::Demo::SqlAround.parse_insert_with_values(params[:sql])
    rescue => e
      @output = e
    end
    haml :insert_with_values
  end
end
