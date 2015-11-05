#encoding: utf-8
require "qiniu"
require "fileutils"

desc "cdn with qiniu."
namespace :qiniu do
  def upload_file_2_qiniu(local_file)
    config = {
      :access_key => Settings.cdn.qiniu.access_key,
      :secret_key => Settings.cdn.qiniu.secret_key
    }
    bucket     = Settings.cdn.qiniu.bucket
    key        = File.basename(local_file)
    Qiniu.establish_connection!(config)

    put_policy = Qiniu::Auth::PutPolicy.new(bucket)
    uptoken = Qiniu::Auth.generate_uptoken(put_policy)

    code, result, response_headers = Qiniu::Storage.stat(bucket, key)
    if code == 200
      puts "[%s] already exist in [%s] then delete..." % [key, bucket]
      code, result, response_headers = Qiniu::Storage.delete(bucket, key)
      raise "Fail delete [%s] in [%s] with qiniu." % [key, bucket] if code != 200
    else
      puts "[%s] not found in [%s] then upload..." % [key, bucket]
    end

    code, result, response_headers = Qiniu::Storage.upload_with_put_policy(
        put_policy,
        local_file,
        key       # key
    )
    puts "[%s] upload successfully." % key
    return code == 200
  end

  desc "download backup file "
  task :download => :environment do
    bucket = Settings.qiniu.bucket
    key    = bak_file_name(days_ago(1))
    download_url = "http://%s.qiniudn.com/%s" % [bucket, key]

    tmp_file = Rails.root.join("tmp/%s" % key)
    File.delete(tmp_file) if File.exist?(tmp_file)

    curl_command = "curl -o %s %s" % [tmp_file, download_url]
    system(curl_command)

    # use `2>&1` then ruby variable will catch the output
    extract_command = "cd %s && tar -xvf %s 2>&1" % [Rails.root.join("tmp"), key]
    extract_file = `#{extract_command}`.split(/\s+/).last rescue nil
    if extract_file
      filepath = Rails.root.join("tmp", extract_file)
      rake_command = "bundle exec rake my_db:restore RAILS_ENV=production BACKUP_FILE=%s" % filepath
      `#{rake_command}`
      rake_command = "bundle exec rake db:migrate"
      `#{rake_command}`
    else
      puts "Error: fail download from qiniu."
    end
  end

  desc "tasks for upload."
  namespace :upload do
    desc "upload assets file."
    task :assets => :environment do
      assets_path = File.join(ENV["APP_ROOT_PATH"], "app/assets")
      raise "assets path not exist:#{assets_path}" unless File.exist?(assets_path)

      today = Time.now.strftime("%Y%m%d")
      Dir.glob(assets_path + "/*/*").each do |asset_file_path|
        if File.file?(asset_file_path)
          if File.mtime(asset_file_path).strftime("%Y%m%d").eql?(today)
            upload_file_2_qiniu(asset_file_path)
          else
            puts "NOT Upload For NOT Modified Today: #{asset_file_path}"
          end
        else
          puts "NOT File: #{asset_file_path}"
        end
      end
    end
  end
end
