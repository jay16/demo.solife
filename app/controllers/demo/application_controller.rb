#encoding: utf-8
module Demo
  class ApplicationController < ApplicationController
    helpers Demo::ApplicationHelper

    get "/:file.pdf" do
      send_file File.join(ENV["APP_ROOT_PATH"], "app/views/demo/pdf_js/iSearch.pdf")
    end
  end
end
