#encoding: utf-8
require "./config/boot.rb"

{ "/"                       => "HomeController",
  "/users"                  => "UsersController",
  "/weixin"                 => "WeiXin::ApplicationController",
  "/weixin/solife"          => "WeiXin::SOLifeController",
  "/weixin/nba_report"      => "WeiXin::NBAReportController",
  "/account"                => "Account::HomeController",
  "/account/users"          => "Account::UsersController",
  "/account/callbacks"      => "Account::CallbacksController",
  "/account/callback_datas" => "Account::CallbackDatasController",
  "/account/weixiners"      => "Account::WeixinersController",
  "/account/messages"       => "Account::MessagesController",
  "/cpanel"                 => "Cpanel::HomeController",
  "/cpanel/users"           => "Cpanel::UsersController",
  "/cpanel/weixiners"       => "Cpanel::WeixinersController",
  "/cpanel/messages"        => "Cpanel::MessagesController",
  "/cpanel/change_log"      => "Cpanel::ChangeLogController",
  "/demo"                   => "Demo::HomeController",
  "/demo/alipay"            => "Demo::TransactionsController",
  "/demo/openfind"          => "Demo::OpenfindController",
  "/demo/pdfjs"             => "Demo::PdfJSController",
  "/demo/nxscae"            => "Demo::NxscaeController"
}.each_pair do |path, mod|
  clazz = mod.split("::").inject(Object) { |obj,c| obj.const_get(c) }
  map(path) { run clazz }
end

