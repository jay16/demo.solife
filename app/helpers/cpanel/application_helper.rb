#encoding: utf-8
module Cpanel
  module ApplicationHelper

    # 不同层级的页面，路径设置不同
    def render_page_header
      haml :"../../layouts/_cpanel_header"
    end
  end
end
