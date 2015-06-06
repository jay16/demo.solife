#encoding: utf-8 
require "open-uri"
require "csv"
require "zip"
require "fileutils"
class Demo::OpenfindController < Demo::ApplicationController
  set :views, File.join(ENV["VIEW_PATH"], "demo/openfind")
  set :layout, :"../../layouts/layout"

  before do
    set_seo_meta("Openfind电子报", "Openfind,电子报,名单,模板", "Openfind电子报名单及模板整理辅助")
  end

  # Get /demo/openfind
  get "/" do
    haml :index, layout: settings.layout
  end

  # Post /demo/openfind/members
  post "/members" do
    begin
      filepath = csv_file_for(params[:members][:url])
      filename = File.basename(filepath)
      send_file(filepath, :filename => filename)
    rescue => e
      flash[:danger] = "请确保链接在浏览器可以正常打开:#{params[:members][:url]}"
      redirect "/demo/openfind"
    end
  end

  # Post /demo/openfind/template
  post "/template" do
    begin
      filepath = dl_template
      filename = File.basename(filepath)
      send_file(filepath, :filename => filename)
    rescue => e
      flash[:warning] = "请确保链接在浏览器可以正常打开:#{params[:members][:url]}"
      redirect "/demo/openfind"
    end
  end

  def dl_template
    tmp_path = File.join(ENV["APP_ROOT_PATH"], "tmp")
    FileUtils.mkdir(tmp_path) if !File.exist?(tmp_path)
    #创建根目录
    openfind_path = File.join(tmp_path, "openfind/")
    File.exist?(openfind_path) ? `rm -fr #{openfind_path}/*` : Dir.mkdir(openfind_path) 
    images_path = File.join(openfind_path,"images")
    Dir.mkdir(images_path) unless File.exist?(images_path)
    
    #下载image并修改链接地址
    doc = Nokogiri::HTML(open(params[:template][:url]).read)
    doc.css("img").each do |img|
      img_src = img.attr("src")
      next if !%w(.jpg .jpeg .gif .png).include?(File.extname(img_src).downcase)
      begin
        img_src = concat_img_src(params[:template][:url], img_src) if !%r{^(http|https)://(.*)}.match(img_src)
        img_data = open(img_src){|f| f.read }
        puts img_src
      rescue => e
         puts e.to_s
      else
        new_img = File.join(images_path,File.basename(img_src))
        open(new_img,"wb") { |f| f.write(img_data) }
        img["src"] = File.join("images",File.basename(img_src))
      end
    end
    #创建index页面
    File.open(File.join(openfind_path,"index.html"), "wb") { |file| file.puts doc.to_s }
    zip_file_path = File.join(tmp_path,"openfind #{Time.now.strftime("电子报模板_%Y%m%d%H%M%S")}.zip")

    generate_zip(openfind_path,zip_file_path)
  #  io = File.open(zf_dir)
  #  io.binmode
  #  send_data(io.read,:filename => "openfind #{Time.now.strftime("%Y年%m月电子报模板")}.zip",:disposition => "attachment")
  #  io.close
  end

  def concat_img_src(url, path)
    url.chop! if url.end_with?("/")
    path = ["/", path].join if !path.start_with?("/")
    [url, path].join
  end

  def generate_zip(been_zip_dir, zip_file_path)
    Zip::ZipFile.open(zip_file_path, Zip::ZipFile::CREATE) do |zipfile|
      Dir[File.join(been_zip_dir, '**', '**')].each do |file|
        zipfile.add(file.sub(been_zip_dir, ''), file)
      end
    end  
    return zip_file_path
  end  
  
  def csv_file_for(url)
    csv_file = Time.now.strftime("Openfind名单_%Y%m%d%H%M%S.csv")
    tmp_path = File.join(ENV["APP_ROOT_PATH"], "tmp")
    FileUtils.mkdir(tmp_path) if !File.exist?(tmp_path)
    csv_path = File.join(tmp_path, csv_file)

    CSV.open(csv_path, "wb:UTF-8") do |csv|
      csv << ["name", "email"]
      emails = open(url).read.scan(/\w+(?:[\.\-]\w+)*@\w+(?:[\.\-]\w+)*/)

      emails.each do |email|
        csv << [email.split(/@/)[0], email]
      end if !emails.empty?
    #  doc = Nokogiri::HTML(open(url).read)
    #  doc.css("p").each do |p|
    #   tmp = p.content.strip
    #   tmp.gsub!(/[" "]|[" "]|[";"]/,"")
    #   csv << [tmp.split("@")[0], tmp]
    #  end
    end
    return csv_path
  end

  def xls_content_for(url)
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "Sheet1"
    
    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10
    sheet1.row(0).default_format = blue
    sheet1.row(0).concat %w{name email}
    row_index = 1
    
    #url = "http://cndemo.openfind.com/china/order/show.php"
    doc = Nokogiri::HTML(open(url).read)
    doc.css("p").each do |i|
     tmp = i.content.strip
     tmp.gsub!(/[" "]|[" "]|[";"]/,"")
     sheet1[row_index,0] = tmp.split("@")[0]
     sheet1[row_index,1] = tmp
     row_index += 1
    end

    book.write xls_report
    xls_report.string
  end
end
