# coding: utf-8
module Nxscae
  module LayoutHelper

    def high_chart(placeholder, object, &block)
      object.html_options.merge!({:id => placeholder})
      object.options[:chart][:renderTo] = placeholder
      high_graph(placeholder, object, &block).concat(content_tag("div", "", object.html_options))
    end

    # def high_stock(placeholder, object, &block)
    #   object.html_options.merge!({:id => placeholder})
    #   object.options[:chart][:renderTo] = placeholder
    #   high_graph_stock(placeholder, object, &block).concat(content_tag("div", "", object.html_options))
    # end

    def high_graph(placeholder, object, &block)
      build_html_output("Chart", placeholder, object, &block)
    end

    # def high_graph_stock(placeholder, object, &block)
    #   build_html_output("StockChart", placeholder, object, &block)
    # end

    def build_html_output(type, placeholder, object, &block)
      options_collection = [generate_json_from_hash(object.options)]
      options_collection << %|"series": [#{generate_json_from_array(object.series_data)}]|

      core_js =<<-EOJS
        var options = { #{options_collection.join(',')} };
        #{capture(&block) if block_given?}
        window.chart_#{placeholder.underscore} = new Highcharts.#{type}(options);
      EOJS

      if defined?(request) && request.respond_to?(:xhr?) && request.xhr?
        graph =<<-EOJS
        <script type="text/javascript">
        (function() {
          #{core_js}
        })()
        </script>
        EOJS
      elsif defined?(Turbolinks) && request.headers["X-XHR-Referer"]
        graph =<<-EOJS
        <script type="text/javascript">
        (function() {
          var f = function(){
            document.removeEventListener('page:load', f, true);
            #{core_js}
          };
          document.addEventListener('page:load', f, true);
        })()
        </script>
        EOJS
      else
        graph =<<-EOJS
        <script type="text/javascript">
        (function() {
          var onload = window.onload;
          window.onload = function(){
            if (typeof onload == "function") onload();
            #{core_js}
          };
        })()
        </script>
        EOJS
      end

      if defined?(raw)
        return raw(graph)
      else
        return graph
      end

    end

    private

    def generate_json_from_hash hash
      hash.each_pair.map do |key, value|
        k = key.to_s.camelize.gsub!(/\b\w/) { $&.downcase }
        %|"#{k}": #{generate_json_from_value value}|
      end.flatten.join(',')
    end

    def generate_json_from_value value
      if value.is_a? Hash
        %|{ #{generate_json_from_hash value} }|
      elsif value.is_a? Array
        %|[ #{generate_json_from_array value} ]|
      elsif value.respond_to?(:js_code) && value.js_code?
        value
      else
        value.to_json
      end
    end

    def generate_json_from_array array
      array.map { |value| generate_json_from_value(value) }.join(",")
    end



    # custom methods
    def highchart_generator
      xAxis, columns1, column_names, columns2 = [], [], [], []
      @nxscae_models.first.nxscae_dayinfos.all(:cur_price.gt => 0, :limit => 15, :order => :id.desc).reverse.each do |timeline|
          xAxis << timeline.time[5..-4] rescue "bad time" # 2015-07-24 01:02:03 => 07-24 01:02
          column_data1, column_data2 = [], []
          @nxscae_models.each do |nxscae|
            column_names << nxscae.fullname
            dayinfo = nxscae.nxscae_dayinfos.first(time: timeline.time)
            column_data1 << (dayinfo ? dayinfo.cur_price : 0)
            column_data2 << (dayinfo ? dayinfo.current_gains : 0)
          end
          columns1 << column_data1
          columns2 << column_data2
      end
      columns1 = columns1.transpose
      columns2 = columns2.transpose
      puts "highchart_generator"
      
      @chart = LazyHighCharts::HighChart.new('graph') do |f|
          f.title({text: "趋势图表"})
          f.xAxis({:categories => xAxis})
          f.labels(:items=>
            [:html=>"", 
             :style=>{:left=>"40px", :top=>"8px", :color=>"black"} ])
          f.yAxis [
            {:title => {:text => "最新价格", :margin => 70} },
            {:title => {:text => "涨跌幅"}, :opposite => true},
          ]
          columns1.each_with_index do |column_data,index|
            f.series(:type=> 'spline',:yAxis => 0,:name=> column_names[index],:data=> column_data)
          end
          # columns2.each_with_index do |column_data,index|
          #   f.series(:type=> 'spline',:yAxis => 1,:name=> column_names[index],:data=> column_data)
          # end
          # f.series(:type=> 'spline',:name=> 'Average', 
          #          :data=> [3, 2.67, 3, 6.33, 3.33])
      end
    end
  end
end
