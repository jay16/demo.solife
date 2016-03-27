module ApplicationHelper

  # flash#success/warning/danger message will show
  # when redirect between action
  def flash_message
    return if not defined?(flash) or flash.empty?
    # hash key must be symbol
    hash = flash.inject({}) { |h, (k, v)| h[k.to_s] = v; h; }
    # bootstrap#v3 [alert] javascript plugin
    flash.keys.map(&:to_s).grep(/warning|danger|success/).map do |key|
      close = link_to("&times;", "#", class: "close", "data-dismiss" => "alert")
      tag(:div, {content: "#{close}#{hash[key]}", class: "alert alert-#{key}", role: "alert" }) 
    end.join
  end

  MOBILE_USER_AGENTS =  'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                        'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                        'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                        'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                        'webos|amoi|novarra|cdm|alcatel|pocket|iphone|mobileexplorer|mobile'
  # check remote client whether is mobile
  # define different layout
  def mobile?
    user_agent = request.user_agent.to_s.downcase rescue "false"
    return false if user_agent =~ /ipad/
    user_agent =~ Regexp.new(MOBILE_USER_AGENTS)
  end

  # generate keywords from obj
  # for js search function
  def keywords(obj)
    dirty_words = %w[ip browser created_at updated_at id]
    obj.class.properties.map(&:name)
      .reject { |v| dirty_words.include?(v.to_s) }
      .map { |var| obj.instance_variable_get("@%s" % var).to_s }
      .join(" ")
  end

  # 不同层级的页面，路径设置不同
  def render_page_header
    #haml File.join(ENV["APP_ROOT_PATH"], "views/layouts/_header").to_sym
    haml :"../layouts/_header"
  end

  def render_page_title
    web_title = Settings.website.title
    web_title = %(#{@page_title} | #{web_title}) if @page_title

    %(<title>#{web_title}</title>)
  end
 
  def asset_link_with_cdn(filepath)
    if ENV["RACK_ENV"].eql?("production") and 
      !filepath.start_with?("http://", "https://")
      
      filepath = "#{Settings.cdn.qiniu.out_link}/#{File.basename(filepath)}"
    end
    filepath
  end

  def javascript_include_tag_with_cdn(filepath)
    tag_with_cdn(:javascript_include_tag, filepath)
  end
  def stylesheet_link_tag_with_cdn(filepath) 
    tag_with_cdn(:stylesheet_link_tag, filepath)
  end
  def image_tag_with_cdn(filepath)
    tag_with_cdn(:image_tag, filepath)
  end

  def tag_with_cdn(method_name, filepath)
    if ENV["RACK_ENV"].eql?("production") and 
      !filepath.start_with?("http://", "https://")
      
      filepath = "#{Settings.cdn.qiniu.out_link}/#{File.basename(filepath)}"
    end

    send(method_name, filepath)
  end

  def human_filesize(filepath)
    filesize = File.size?(filepath) || 0

    human_units = %w(K M G T P)
    human_sizes = []
    while filesize > 1024
      filesize /= 1024
      human_sizes.push(filesize % 1024)
    end

    human_group = []
    human_sizes.each_with_index do |size, index|
      human_group.push(%(#{size}#{human_units[index]}))
    end

    human_group.reverse.join
  rescue => e
    e.message
  end

  # 每月按30天处理
  # **测试月会有误差**
  #
  # human_time('2016-03-23 15:24:45', '2016-03-23 15:24:00') => '45秒'
  # human_time('2016-03-23 15:25:45', '2016-03-23 15:24:00') => '1分钟45秒'
  # human_time('2016-03-23 16:25:45', '2016-03-23 15:24:00') => '1小时1分钟45秒'
  # human_time('2016-03-24 16:25:45', '2016-03-23 15:24:00') => '1天1小时1分钟45秒'
  # human_time('2016-03-24 16:24:00', '2016-03-23 15:24:00') => '1天1小时'
  # human_time('2016-03-24 16:25:00', '2016-03-23 16:24:00') => '1天1分钟'
  # human_time('2017-04-24 16:25:45', '2016-03-23 15:24:00') => '1年1月'
  def human_time(time_end, time_begin)
    human_units = %w(秒 分钟 小时 天 月 年 轮)
    human_multi = [60, 60, 24, 30, 12, 12]
    time_diff = (time_end - time_begin).to_i
    index = 0
    human_sizes = []
    human_sizes.push(time_diff % 60)
    while time_diff >= human_multi[index]
      time_diff /= human_multi[index]
      human_sizes.push(time_diff % human_multi[index + 1])
      index += 1
    end

    human_group = []
    human_sizes.each_with_index do |size, i|
      next if size.zero?
      human_group.push(%(#{size}#{human_units[i]}))
    end

    human_group.reverse.join
  rescue => e
    e.message
  end

  # File vendor/rails/actionpack/lib/action_view/helpers/number_helper.rb, line 125
  def number_with_delimiter(number, delimiter = ',', separator = '.')
    parts = number.to_s.split('.')
    parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
    parts.join separator
  rescue
    number
  end
end
