# encoding: utf-8
require 'erb'
require 'lib/sinatra/extension_redis'

namespace :redis do
  desc 'generate config file'
  task generate_config: :environment do
    config_path = %(#{ENV['APP_ROOT_PATH']}/config/redis.conf)
    template_path = %(#{config_path}.erb)
    File.open(config_path, 'w:utf-8') do |file|
      file.puts ERB.new(File.read(template_path)).result
    end
  end

  desc 'login stat write mysql'
  task login_stat_2_mysql: :environment do
    register Sinatra::Redis

    User.all.each do |user|
      redis_key = %(/user_num/#{user.user_num}/login_stat)
      next unless redis.hexists(redis_key, 'sign_in_count')
      next unless redis.hget(redis_key, 'sign_in_count').to_i > user.sign_in_count

      user.update_columns(
        last_login_at: redis.hget(redis_key, 'last_login_at').to_time,
        last_login_ip: redis.hget(redis_key, 'last_login_ip'),
        last_login_browser: redis.hget(redis_key, 'last_login_browser'),
        last_login_version: redis.hget(redis_key, 'last_login_version'),
        sign_in_count: redis.hget(redis_key, 'sign_in_count').to_i
      )
    end
  end
end
