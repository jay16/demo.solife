# encoding: utf-8
require './config/boot.rb'
# # Unicorn self-process killer
require 'unicorn/worker_killer'

# Max requests per worker(200 - 500)
use Unicorn::WorkerKiller::MaxRequests, 200, 500

# Max memory size (RSS) per worker(192M - 256M)
use Unicorn::WorkerKiller::Oom, (192*(1024**2)), (256*(1024**2))

{ 
  '/' => 'Demo::HomeController',
  '/openfind' => 'Demo::OpenfindController',
  '/ball' => 'Demo::MoneyBallController'
}.each_pair do |path, mod|
  clazz = mod.split('::').inject(Object) { |a, b| a.const_get(b) }
  map(path) { run clazz }
end
