#encoding: utf-8
require "net/ssh"
require "net/scp"
desc "remote deploy application."
namespace :remote do
  def encode(data)
    data.to_s.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'})
  end

  def execute!(ssh, command)
    ssh.exec!(command) do  |ch, stream, data|
      puts "%s:\n%s" % [stream, encode(data)]
    end
  end

  desc "scp local config files to remote server."
  task :deploy => :environment do
    remote_root_path = Settings.server.app_root_path
    local_config_path  = "%s/config/*.yaml" % ENV["APP_ROOT_PATH"]
    remote_config_path = "%s/config/" % remote_root_path

    Net::SSH.start(Settings.server.host, Settings.server.user, :password => Settings.server.password) do |ssh|
      command = "cd %s && git reset --hard HEAD && git pull" % remote_root_path
      execute!(ssh, command)

      # # check whether remote server exist yaml file
      # Dir.glob(local_config_path).each do |yaml_path|
      #   ssh.scp.upload!(yaml_path, remote_config_path) do |ch, name, sent, total| 
      #     print "\rupload #{name}: #{(sent.to_f * 100 / total.to_f).to_i}%"
      #   end
      #   puts "\n"
      # end

      command = "cd %s && /bin/sh unicorn.sh restart" % remote_root_path
      execute!(ssh, command)

      # database_name = "%s_%s" % [ENV["APP_NAME"], "production"]
      # remote_db_path = "%s/db/%s.db" % [remote_root_path, database_name]
      # local_db_path  = "%s/db/%s.db" % [ENV["APP_ROOT_PATH"], database_name]

      # File.delete(local_db_path) if File.exist?(local_db_path)
      # ssh.scp.download!(remote_db_path, local_db_path)
    end
  end
end
