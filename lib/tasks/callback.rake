#encoding: utf-8
require "timeout"
desc "callback request."
namespace :callback do
  def run_command(shell, whether_show_log=true, whether_reject_empty=true)
    result = IO.popen(shell) do |stdout| 
        stdout.readlines#.reject(&method) 
    end.map { |l| l.is_a?(String) ? string_format(l) : l }
    status = $?.exitstatus.zero?
    if !status or whether_show_log
      shell  = string_format(shell).split(/\n/).map { |line| "\t`" + line + "`" }.join("\n")
      result = ["bash: no output"] if result.empty?
      if result.length > 100
        resstr = "\t\tbash: output line number more than 100 rows."
      else
        resstr = result.map { |line| "\t\t" + line }.join
      end
      puts "%s\n\t\t==> %s\n%s\n" % [shell, status, resstr]
    end
    return result.unshift(status)
  end 

  def uniq_task(t)  
    $0 = ["rake", t.name].join(":")  

    # USER PID %CPU %MEM VSZ RSS TT STAT STARTED TIME COMMAND
    # 0    1   2    3    4   5   6  7    8       9    10
    processes = %x{ps aux|grep #{$0}|grep -v "grep"}.split("\n")
    return true if processes.empty?

    processes = processes.map do |process|
      user, pid, cpu, mem, vsz, rss, tt, stat, started, time, *command = process.split
      [user, pid, cpu, mem, vsz, rss, tt, stat, started, time, command.join(" ")]
    end.find_all { |p| p.last == $0 }

    if processes.size > 1 # point! not 0 for this process will be contained
      # whether exist zombie process
      zombies = processes.find_all { |p| p[7] == "Z" }
      if zombies.size > 1
        zombies.each { |p| %x{kill -kill #{p[1]}} }
        puts_with_space("[WARNING] find [%d] zombie process and killed them." % zombies.size)
      end
      # TODO: 
      # 1. should redetect rake process is running after kill zombie process
      return false
    else
      return true
    end
  end  

  def last_time(info, &block)
    now  = Time.now
    puts "Started at %s" % now.strftime("%Y-%m-%d %H:%M:%S")
    bint = now.to_f
    yield
    now  = Time.now
    eint = now.to_f
    printf("Completed %s in %s - %s\n\n", now.strftime("%Y-%m-%d %H:%M:%S"), "%dms" % ((eint - bint)*1000).to_i, info)
  end

  def http_get(url, echostr, callback_data)
    begin
      response = HTTParty.get "%s?echostr=%s" % [url, echostr]
      if response.body == echostr
        return true
      else
        callback_data.update({response: "%s <=> %s" % [response.body, echostr], result: "fail#get"})
        return false
      end
    rescue => e
      callback_data.update({response: e.message, result: "fail#get"})
      return false
    end
  end

  def http_post(url, callback_data)
    begin
      Timeout::timeout(4) do
        params = ::JSON.parse(callback_data.params) 
        params[:format] = "json"
        response = HTTParty.post url, body: params, headers: {'ContentType' => 'application/json'} 
        callback_data.update({response: response.body, result: "ok"})
      end
    rescue => e
      callback_data.update({response: e.message, result: "fail#post"})
    end
  end

  desc "callback request action."
  task :request do
    CallbackData.all(result: "waiting").each do |callback_data|
      url      = callback_data.callback.outer_url
      echostr  = Time.now.strftime("%y%m%d%H%M%S")

      if http_get(url, echostr, callback_data)
        http_post(url, callback_data)
        puts callback_data.result + "\n\t" + callback_data.response
      else
        puts callback_data.result + "\n\t" + callback_data.response
      end

      filepath = File.join(ENV["APP_ROOT_PATH"], "public/callbacks")
      cbfile   = callback_data.id.to_s + ".cb"
      run_command("cd #{filepath} && test -f #{cbfile} && rm #{cbfile}")
    end
  end

  desc "callback main"
  task :main => :environment do |t|
    last_time "rake#task => %s" % t.name do
      if uniq_task(t)  
        Rake::Task["callback:request"].invoke
      else
        puts "\tLast Task is running."
      end
    end
  end
end
