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
    last_modified @local_latest_update
    etag  md5_key(@local_latest_update)
    @nxscae_models = NxscaeModel.all(:fullname => ["虎首小铜章", "羊年小铜章","鸡首铜章"], :order => :updated_at.desc)

    #collection = NxscaeDayinfo.all(:nxscae_model_id => [1], :cur_price.gt => 0, :limit => 15, :order => [:updated_at.asc])#.map { |day| day.updated_at }
    #query = collection.query
    #puts DataMapper.repository.adapter.send(:select_statement,query)
    #@nxscae_models.first.nxscae_dayinfos.all(:cur_price.gt => 0, :limit => 15, :order => :id.desc).inspect
    haml :index, layout: settings.layout
  end

end
