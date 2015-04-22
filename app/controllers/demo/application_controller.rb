#encoding: utf-8
module Demo; end
class Demo::ApplicationController < ApplicationController
 
  def respond_with_json hash, code = nil
    content_type "application/json"
    body   hash.to_json
    status code || 200
  end

  def disposition_file(file_type)
    file = File.join(ENV["APP_ROOT_PATH"],"app/assets/#{file_type}/#{params[:file]}")
    send_file(file, :disposition => :inline) if File.exist?(file)
  end
end
