# execute linux shell command
# return array with command result
# [execute status, execute result] 
def run_command(cmd)
  IO.popen(cmd) do |stdout|
    stdout.reject(&:empty?)
  end.unshift($?.exitstatus.zero?)
end 

cmd = "cd /Users/lijunjie/Code/work/wohecha && bundle exec rspec spec/controller/generate_static_files_spec.rb"
puts "#" * 10
puts run_command(cmd).join("\n")
puts "#" * 10
