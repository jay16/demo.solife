#encoding: utf-8 
class Demo::ISearchController < Demo::ApplicationController
  set :views, File.join(ENV["VIEW_PATH"], "demo/isearch")
  set :layout, "../../layouts/layout".to_sym

  # get /demo/isearch
  get "/" do
    filepath = File.join(settings.views, "iSearch.plist")
    if File.exist?(filepath)
      IO.read(filepath)
    else 
      "file not found: iSearch.plist"
    end
  end

  get "/:filename" do
    filepath = File.join(settings.views, params[:filename])
    if(params[:filename] && File.exist?(filepath))
      send_file(filepath, filename: params[:filename])
    else
      "file not found: %@" % params[:filename]
    end
  end

  post "/" do
    respond_with_json params
  end
end
