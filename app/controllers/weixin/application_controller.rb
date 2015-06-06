#encoding: utf-8
require "timeout"
module WeiXin
  class ApplicationController < ApplicationController
	  before do
      set_seo_meta("微信接口", "微信公众平台, 开发者, 第三方接口", "微信公众平台, 开发者第三方接口")
	  end

    # GET /weixin
    get "/" do
      redirect_to "/"
    end
  end 
end
