class UrlProxy
  class << self
    # read_html_to_local_with_rescue
    def read_html_to_local(output, url, param={})
      begin
        html = _read_html_to_local(output, url, param)
      rescue => e
        html = "<h1>Read Html Fail.</h1>"
        html << "<h3>%s</h3>" % e.message
        html << "<div>%s</div>" % e.backtrace.join("<br>")
      end

      File.open(output, "w+") do |file|
        file.puts html.force_encoding("UTF-8")
      end
    end

    def _read_html_to_local(output, url, param={})
      response = RestClient.get url, param
      html = response.to_s.force_encoding("UTF-8")
      #html.scan(/<script.*?>.*?<\/script>/i).each do |script|
      #  html.gsub!(script, "")
      #end
      _head = html.scan(/<head>(.*?)<\/head>/i).flatten[0] || ""
      _body = html.scan(/<body>(.*?)<\/body>/i).flatten[0] || html
      _head << stylesheet_link_tag("/stylesheets/output.scss")
      _body << javascript_include_tag("/javascripts/jquery-1.9.0.js")
      _body << javascript_include_tag("/javascripts/output.js")

      html =  "<head>%s</head>" % _head
      html << "<body>%s</body>" % _body
      return html
    end

    def stylesheet_link_tag(filepath)
      %Q{<link rel="stylesheet" type="text/css" href="#{filepath}">}
    end
    def javascript_include_tag(filepath)
      %Q{<script type="text/javascript" async="" src="#{filepath}"></script>}
    end
  end
end
