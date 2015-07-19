#encoding: utf-8
require "lib/utils/weixin/solife/nxscae.rb"
require "lib/utils/weixin/solife/nxscae.rb"
desc "callback request."
namespace :nxscae do

  desc "update nxscae tables info"
  task :update => :environment do
    options = {nxscae_stock_url: Settings.nxscae.stock_url }
    output = ::Nxscae::Tables.search([], options)
    puts output
  end
end