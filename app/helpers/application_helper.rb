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
    site_name, title = "SOLife", "title"
    begin
      title = @page_title ? "#{site_name} | #{@page_title}" : "#{site_name} | Segment Of Life." 
    rescue => e
     title = e.message
    end
    "<title>%s</title>" % title
  end

  def javascript_include_tag_with_cdn(file_name)
    tag_with_cdn(:javascript_include_tag, file_name)
  end
  def stylesheet_link_tag_with_cdn(file_name) 
    tag_with_cdn(:stylesheet_link_tag, file_name)
  end
  def image_tag_with_cdn(file_name)
    tag_with_cdn(:image_tag, file_name)
  end

  def tag_with_cdn(method_name, file_name)
    if ENV["RACK_ENV"].eql?("production") and 
      !file_name.start_with?("http://", "https://")
      
      file_name = "#{Settings.cdn.qiniu.out_link}/#{File.basename(file_name)}"
    end

    send(method_name, file_name)
  end
end
