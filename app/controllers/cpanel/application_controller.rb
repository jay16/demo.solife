#encoding: utf-8
module Cpanel
  class Cpanel::ApplicationController < ApplicationController
    helpers Cpanel::ApplicationHelper

    before do
      authenticate!
      redirect "/account" if not current_user.admin?
    end
  end
end