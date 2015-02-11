#encoding: utf-8 
class Cpanel::ChangeLogController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/change_log"
  set :layout, :"../layouts/layout"

  # Get /cpanel/change_log
  get "/" do
    @change_logs = ChangeLog.all

    haml :index, layout: settings.layout
  end

  # Get /cpanel/change_log/new
  get "/new" do
    @change_log = ChangeLog.new

    haml :new, layout: settings.layout
  end

  # Post /cpanel/change_log
  post "/" do
    @change_log = ChangeLog.new(params[:change_log])
    @change_log.author = "%s#%d" % [current_user.name, current_user.id]
    if @change_log.save_with_logger
      filepath = ::File.join(ENV["APP_ROOT_PATH"], "public/change_logs", @change_log.id.to_s+".cl")
      File.open(filepath, "w+") { |file| file.puts(@change_log.inspect) }
    end

    redirect "/cpanel/change_log/%d" % @change_log.id
  end

  get "/:id" do
    @change_log = ChangeLog.first(id: params[:id])

    haml :show, layout: settings.layout
  end

  # Get /cpanel/change_log/:id
  get "/:id/edit" do
    @change_log = ChangeLog.first(id: params[:id])

    haml :edit, layout: settings.layout
  end

  # Post /cpanel/change_log/:id
  post "/:id" do
    @change_log = ChangeLog.first(id: params[:id])
    source = @change_log.source
    unless @change_log.source.split(/\s+/).include?("web")
      source += " web"
    end
    change_log_params = params[:change_log].merge({ 
      editor: "%s#%d" % [current_user.name, current_user.id],
      source: source
    })
    @change_log.update(change_log_params)

    redirect "/cpanel/change_log/%d" % @change_log.id
  end
end
