#encoding: utf-8
module Demo; end
class Demo::ApplicationController < ApplicationController
 
  def disposition_file(file_type)
    file = File.join(ENV["APP_ROOT_PATH"],"app/assets/#{file_type}/#{params[:file]}")
    send_file(file, :disposition => :inline) if File.exist?(file)
  end
end
