# encoding: utf-8
require './config/boot.rb'

{ '/'                       => 'HomeController',
  '/users'                  => 'UsersController',
  # '/weixin'                 => 'WeiXin::ApplicationController',
  # '/weixin/solife'          => 'WeiXin::SOLifeController',
  # '/account'                => 'Account::HomeController',
  # '/account/users'          => 'Account::UsersController',
  # '/account/callbacks'      => 'Account::CallbacksController',
  # '/account/callback_datas' => 'Account::CallbackDatasController',
  # '/account/weixiners'      => 'Account::WeixinersController',
  # '/account/messages'       => 'Account::MessagesController',
  # '/cpanel'                 => 'Cpanel::HomeController',
  # '/cpanel/users'           => 'Cpanel::UsersController',
  # '/cpanel/weixiners'       => 'Cpanel::WeixinersController',
  # '/cpanel/messages'        => 'Cpanel::MessagesController',
  # '/cpanel/change_log'      => 'Cpanel::ChangeLogController',
  '/demo'                   => 'Demo::HomeController',
  '/demo/openfind'          => 'Demo::OpenfindController',
  '/demo/money_ball'        => 'Demo::MoneyBallController'
}.each_pair do |path, mod|
  clazz = mod.split('::').inject(Object) { |a, b| a.const_get(b) }
  map(path) { run clazz }
end
