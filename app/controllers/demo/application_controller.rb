#encoding: utf-8
module Demo
  class ApplicationController < ApplicationController
    helpers Demo::ApplicationHelper

    before do
      set_seo_meta("实验室", "SOLife,实验室", "segment of jay's life!")
    end

    get "/:file.pdf" do
      send_file File.join(ENV["APP_ROOT_PATH"], "app/views/demo/pdf_js/iSearch.pdf")
    end
  end
end
