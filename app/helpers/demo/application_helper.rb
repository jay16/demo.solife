# encoding: utf-8
module Demo
  module ApplicationHelper
    def disposition_file(file_type)
      file = File.join(ENV['APP_ROOT_PATH'], "app/assets/#{file_type}/#{params[:file]}")
      send_file(file, disposition: :inline) if File.exist?(file)
    end

    # 不同层级的页面，路径设置不同
    def render_page_header
      haml :"../../layouts/_demo_header"
    end

    def page_title
      "Openfind 电子报 | Demo"
    end
  end
end
