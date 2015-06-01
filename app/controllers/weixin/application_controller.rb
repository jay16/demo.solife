#encoding: utf-8
require "timeout"
module WeiXin
  class ApplicationController < ApplicationController
	  before do
	  end

    # GET /weixin
    get "/" do
      redirect_to "/"
    end
  end 
end
