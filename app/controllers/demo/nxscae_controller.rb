#encoding: utf-8 
class Demo::NxscaeController < Demo::ApplicationController
  set :views, File.join(ENV["VIEW_PATH"], "demo/nxscae")
  set :layout, "../../layouts/layout".to_sym

  before do
    set_seo_meta("nxscae", "nxscae,table,行情", "nxscae产品行情")
  end

  # get /demo/nxscae
  get "/" do
    @nxscae_models = NxscaeModel.all
    haml :index, layout: settings.layout
  end

end
