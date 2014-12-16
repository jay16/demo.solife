#encoding:utf-8
require "qiniu"
desc "tasks assets with cdn"
namespace :cdn do

  def  upload_file_2_qiniu(local_file)
    config = {
      :access_key => Settings.cdn.qiniu.access_key,
      :secret_key => Settings.cdn.qiniu.secret_key
    }
    bucket     = Settings.cdn.qiniu.bucket
    key        = File.basename(local_file)
    Qiniu.establish_connection!(config)

    put_policy = Qiniu::Auth::PutPolicy.new(bucket)
    uptoken = Qiniu::Auth.generate_uptoken(put_policy)

    code, result, response_headers = Qiniu::Storage.stat(
        bucket,
        key   
    )
    if code == 200
      puts "[%s] already exist in [%s] then delete..." % [key, bucket]
      code, result, response_headers = Qiniu::Storage.delete(
          bucket,
          key  
      )
      raise "Fail delete [%s] in [%s] with qiniu." % [key, bucket] if code != 200
    else
      puts "[%s] not found in [%s] then upload..." % [key, bucket]
    end

    code, result, response_headers = Qiniu::Storage.upload_with_put_policy(
        put_policy,
        local_file,
        key             # key
    )
    puts "[%s] upload successfully." % key
    return code == 200
  end

  desc "tasks cdn with qiniu"
  task :qiniu => :environment do
     assets_path = "%s/app/assets" % ENV["APP_ROOT_PATH"]
     count = succ = 0
     %w[javascripts stylesheets images fonts].each do |name|
       folder_path = "%s/%s" % [assets_path, name]
       files = Dir.entries(folder_path).reject { |file| %[. ..].include?(file) }
       puts "folder [%s]: [%d] files." % [name, files.count]
       count += files.count
       files.each_with_index do |file, index|
         puts "folder [%s]: %d/%d" % [name, index+1, files.count]
         local_file = "%s/%s/%s" % [assets_path, name, file]
         succ += 1 if upload_file_2_qiniu(local_file)
       end
     end
     puts "all [%d] files, upload [%d] files successfully." % [count, succ]
  end
end
