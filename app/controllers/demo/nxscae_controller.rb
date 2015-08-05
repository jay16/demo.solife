#encoding: utf-8 
class Demo::NxscaeController < Demo::ApplicationController
  set :views, File.join(ENV["VIEW_PATH"], "demo/nxscae")
  set :layout, "../../layouts/layout".to_sym

  helpers Nxscae::LayoutHelper
  before do
    set_seo_meta("nxscae", "nxscae,table,行情", "nxscae产品行情")
  end

  # get /demo/nxscae
  get "/" do
    @local_latest_update = NxscaeCache.last.updated_at.strftime("%Y/%m/%d %H:%M:%S")
    #last_modified @local_latest_update
    #etag  md5_key(@local_latest_update)
    #@nxscae_models = NxscaeModel.all(:high_price.lt => 2000, :order => :cur_price.desc) #:fullname => ["虎首小铜章", "羊年小铜章","鸡首铜章"], 

    #collection = NxscaeDayinfo.all(:nxscae_model_id => [1], :cur_price.gt => 0, :limit => 15, :order => [:updated_at.asc])#.map { |day| day.updated_at }
    #query = collection.query
    #puts DataMapper.repository.adapter.send(:select_statement,query)
    #@nxscae_models.first.nxscae_dayinfos.all(:cur_price.gt => 0, :limit => 15, :order => :id.desc).inspect
    haml :index, layout: settings.layout
  end

  get "/list" do
    list_type = params[:list] == "simple" ? "simple" : "all"

    local_latest_update = NxscaeCache.last.updated_at.strftime("%Y/%m/%d %H:%M:%S")
    local_latest_update = "%s-%s" % [list_type, local_latest_update]

    last_modified local_latest_update
    etag  md5_key(local_latest_update)
    puts local_latest_update

    if list_type == "simple"
      filepath, array = File.join(ENV["APP_ROOT_PATH"], "tmp/nxscae.focus"), []

      if File.exist?(filepath)
        array = IO.read(filepath).split(",")
      end
      products = NxscaeModel.all(:fullname => array)
    else
      products = NxscaeModel.all
    end

    array = products.map do |nxscae|
      dayinfo = nxscae.latest_info
      {
        code: dayinfo.code,
        fullname: dayinfo.fullname,
        cur_price: dayinfo.cur_price,
        current_gains: dayinfo.current_gains,
        total_amount: dayinfo.total_amount,
        total_money: dayinfo.total_money,
        high_price: dayinfo.high_price,
        low_price: dayinfo.low_price
      }
    end

    hash = {array: array}
    respond_with_json hash
  end

  get "/:code/data" do
    local_latest_update = NxscaeCache.last.updated_at.strftime("%Y/%m/%d %H:%M:%S")
    local_latest_update = "%s-%s" % [params[:code], local_latest_update]

    last_modified local_latest_update
    etag  md5_key(local_latest_update)
    puts local_latest_update
    
    fullname, xAxis, yAxis1, yAxis2 = "unkown", [], [], []
    if nxscae_model = NxscaeModel.first(code: params[:code])
      fullname = nxscae_model.fullname
      nxscae_model.nxscae_dayinfos.all(:cur_price.gt => 0, :limit => 100, :order => :id.desc)
      .reverse.each do |dayinfo|
        xAxis << dayinfo.time[5..-7]
        yAxis1 << dayinfo.cur_price
        yAxis2 << dayinfo.current_gains
      end
    end

    hash = {fullname: fullname, xAxis: xAxis, yAxis1: yAxis1, yAxis2: yAxis2}
    respond_with_json hash
  end

  get "/focus" do
    filepath, array = File.join(ENV["APP_ROOT_PATH"], "tmp/nxscae.focus"), []

    if File.exist?(filepath)
      array = IO.read(filepath).split(",")
    else 
      puts "%s not exist!" % filepath
    end

    hash = {array: array}
    respond_with_json hash
  end

  get "/focus/:operation/:fullname" do
    filepath, array = File.join(ENV["APP_ROOT_PATH"], "tmp/nxscae.focus"), []

    if File.exist?(filepath)
      array = IO.read(filepath).split
    end

    if params[:operation] == "add"
      array.push(params[:fullname])
    elsif params[:operation] == "remove"
      array.delete(params[:fullname])
    elsif params[:operation] == "default"
      array.delete(params[:fullname])
      array.unshift(params[:fullname])
    end

    File.open(filepath, "w+") do |file|
      file.puts(array.join(","))
    end

    "[%s] [%s] successfully." % [params[:operation], params[:fullname]]
  end
end
