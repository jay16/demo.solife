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
    @nxscae_models = NxscaeModel.all(:fullname => ["虎首小铜章", "羊年小铜章","鸡首铜章"], :order => :time.desc)
    last_modified @nxscae_models.first.time
    etag  md5_key(@nxscae_models.first.time)

    haml :index, layout: settings.layout
  end

end
