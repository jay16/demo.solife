# encoding: utf-8
require './config/boot.rb'

{ '/' => 'Demo::HomeController',
  '/openfind' => 'Demo::OpenfindController',
  '/mb' => 'Demo::MoneyBallController',
  '/money_ball' => 'Demo::MoneyBallController'
}.each_pair do |path, mod|
  clazz = mod.split('::').inject(Object) { |a, b| a.const_get(b) }
  map(path) { run clazz }
end
