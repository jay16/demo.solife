#encoding: utf-8
module StringMethods
  def self.included(base)
    base.class_eval do
      [:process_pattern,:process_consume, :cn_convert_num].each do |method_name|
        next unless method_defined?(method_name)
        location = self.method(method_name).source_location rescue next
        next if location[0] == __FILE__

        warn "\tRemove Method - #{method_name} defiend in:\n\t%s\n\tand reload file in \n\t%s" % [location, __FILE__]
        remove_method method_name
      end
    end
  end

  def process_pattern
    unless ENV["APP_ROOT_PATH"]
      puts "\nWARNGING: ENV['APP_ROOT_PATH'] undefined!\n"
    end
    cmd = "%s/lib/utils/processPattern/processPattern '%s'" % [ENV["APP_ROOT_PATH"], self]

    result = IO.popen(cmd) do |stdout| 
        stdout.readlines#.reject(&method) 
    end
    status = $?.exitstatus.zero? rescue false

    shell  = cmd.split(/\n/).map { |line| "\t`" + line + "`" }.join("\n")
    result = ["bash: no output"] if result.empty?
    resstr = result.map { |line| "\t\t" + line }.join
    puts "%s\n\t\t==> %s\n%s\n" % [shell, status, resstr]

    return result.unshift(status)
  end

  # str = "手机钢化膜45元 卸装油88元 测试20元"
  # result:
  # ["手机钢化膜(45元)\n卸装油(88元)\n测试(20元)",264.5]
  def process_consume
      reg = /((\d+\.\d+|\d+)\s*[元|块])/
      str, array, amount = self.clone, [], 0
      while index = str =~ reg
        array << "%s(%s)" % [str[0..index-1], $1]
        amount += $2.to_f
        str = str[index+$1.length..-1]
      end
      puts array.to_s
      # the rest unmatch string also usefully
      array << str if str.length > 0
      puts array.to_s
      [array.compact.join(" \n"), amount] 
  end

  @@cn_nums_map = {
    '〇' => 0,
    '一' => 1,
    '二' => 2,
    '三' => 3,
    '四' => 4,
    '五' => 5,
    '六' => 6,
    '七' => 7,
    '八' => 8,
    '九' => 9,

    '零' => 0,
    '壹' => 1,
    '贰' => 2,
    '叁' => 3,
    '肆' => 4,
    '伍' => 5,
    '陆' => 6,
    '柒' => 7,
    '捌' => 8,
    '玖' => 9,

    '貮' => 2,
    '两' => 2,
  }

  @@cn_decs_map = {
    '个' => 1,
    '十' => 10,
    '拾' => 10,
    '百' => 100,
    '佰' => 100,
    '千' => 1000,
    '仟' => 1000,
    '万' => 10000,
    '萬' => 10000,
    '亿' => 100000000,
    '億' => 100000000,
    '兆' => 1000000000000,
  }
  
  def cn_convert_num
    cn_str = Marshal.load(Marshal.dump(self))
    cn_str = cn_str.gsub("零", "")
    if @@cn_decs_map.keys.include?(cn_str[0])
      cn_str = "一#{cn_str}" 
    end
    @@cn_number = []
    _cn_convert_num(cn_str)
    @@cn_number << 1 unless @@cn_number.length.even?
    @@cn_number.each_slice(2).inject(0) { |sum, k| sum += eval(k.join("*")) }
  end

  def _cn_convert_num(cn_str)
    @@cn_decs_map.keys.reverse.map do |unit|
      if index = cn_str =~ /#{unit}/
        num_block = cn_str[0..index]
        if @@cn_decs_map.keys.include?(num_block[-1])
          @@cn_number << @@cn_decs_map[num_block[-1]].to_s
          _cn_convert_num(num_block[0..-2])
        end
        cn_str = cn_str[index+1..-1]
      else
        if @@cn_nums_map.keys.include?(cn_str)
          @@cn_number << @@cn_nums_map[cn_str].to_i
          break
        end
      end
    end
  end
end
class String
  include StringMethods
end
