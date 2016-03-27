# encoding: utf-8
require 'csv'
require 'zip'
require 'open-uri'
require 'fileutils'
class Demo::OpenfindController < Demo::ApplicationController
  set :views, File.join(ENV['VIEW_PATH'], 'demo/openfind')
  set :layout, :"../../layouts/layout"

  before do
    set_seo_meta("Openfind电子报", "Openfind,电子报,名单,模板", "Openfind电子报名单及模板整理辅助")
  end

  # Get /demo/openfind
  get '/' do
    cache_with_mtime('index')

    haml :index, layout: settings.layout
  end

  # Post /demo/openfind/members
  post '/members' do
    begin
      filepath = csv_file_for(params[:members][:url])
      send_file(filepath, filename: File.basename(filepath))
    rescue => e
      puts e.message
      puts e.backtrace[0..10]
      flash[:danger] = "请确保链接在浏览器可以正常打开:#{params[:members][:url]}"

      redirect to('/demo/openfind')
    end
  end

  # Post /demo/openfind/template
  post '/template' do
    begin
      filepath = dl_template(params[:template][:url])
      send_file(filepath, filename: File.basename(filepath))
    rescue => e
      puts e.message
      puts e.backtrace[0..10]
      flash[:danger] = "请确保链接在浏览器可以正常打开:#{params[:template][:url]}"

      redirect to('/demo/openfind')
    end
  end

  def dl_template(url)
    uri_html = URI.parse(url).read
    tmp_path = File.join(ENV['APP_ROOT_PATH'], 'tmp')
    FileUtils.mkdir(tmp_path) unless File.exist?(tmp_path)
    last_modified = uri_html.last_modified || Time.now
    zip_file_path = File.join(tmp_path, last_modified.strftime('OpenfindEDM_%Y%m%d%H%M%S.zip'))

    unless File.exist?(zip_file_path)
      # 创建根目录
      openfind_path = File.join(tmp_path, 'openfind/')
      File.exist?(openfind_path) ? `rm -fr #{openfind_path}/*` : Dir.mkdir(openfind_path)
      images_path = File.join(openfind_path, 'images')
      Dir.mkdir(images_path) unless File.exist?(images_path)

      # 下载image并修改链接地址
      # doc = Nokogiri::HTML(open(params[:template][:url]).read)
      doc = Nokogiri::HTML(uri_html)
      doc.css('img').each do |img|
        img_src = img.attr('src')
        next unless %w(.jpg .jpeg .gif .png).include?(File.extname(img_src).downcase)
        begin
          img_src = concat_img_src(url, img_src) unless %r{^(http|https)://(.*)} =~ img_src
          img_data = open(img_src, &:read)
          puts img_src
        rescue => e
          puts e.to_s
        else
          new_img = File.join(images_path, File.basename(img_src))
          open(new_img, 'wb') { |f| f.write(img_data) }
          img['src'] = File.join('images', File.basename(img_src))
        end
      end
      # 创建index页面
      File.open(File.join(openfind_path, 'index.html'), 'wb') { |file| file.puts doc.to_s }

      generate_zip(openfind_path, zip_file_path)
    end

    zip_file_path
  end

  def concat_img_src(url, path)
    url.chop! if url.end_with?('/')
    path = ['/', path].join unless path.start_with?('/')
    [url, path].join
  end

  def generate_zip(been_zip_dir, zip_file_path)
    Zip::ZipFile.open(zip_file_path, Zip::ZipFile::CREATE) do |zipfile|
      Dir[File.join(been_zip_dir, '**', '**')].each do |file|
        zipfile.add(file.sub(been_zip_dir, ''), file)
      end
    end
    zip_file_path
  end

  def csv_file_for(url)
    uri_html = URI.parse(url).read
    tmp_path = File.join(ENV['APP_ROOT_PATH'], 'tmp')
    FileUtils.mkdir(tmp_path) unless File.exist?(tmp_path)
    last_modified = uri_html.last_modified || Time.now
    csv_path = File.join(tmp_path, last_modified.strftime('OpenfindMembers_%Y%m%d%H%M%S.csv'))
    puts csv_path
    unless File.exist?(csv_path)
      CSV.open(csv_path, 'wb:UTF-8') do |csv|
        csv << %w(name email)
        emails = uri_html.scan(/\w+(?:[\.\-]\w+)*@\w+(?:[\.\-]\w+)*/)

        emails.each do |email|
          csv << [email.split(/@/)[0], email]
        end unless emails.empty?
      end
    end
    csv_path
  end

  def xls_content_for(url)
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet name: 'Sheet1'

    blue = Spreadsheet::Format.new color: :blue, weight: :bold, size: 10
    sheet1.row(0).default_format = blue
    sheet1.row(0).concat %w(name email)
    row_index = 1

    # url = "http://cndemo.openfind.com/china/order/show.php"
    doc = Nokogiri::HTML(open(url).read)
    doc.css('p').each do |i|
      tmp = i.content.strip
      tmp.gsub!(/[" "]|[" "]|[";"]/, '')
      sheet1[row_index, 0] = tmp.split('@')[0]
      sheet1[row_index, 1] = tmp
      row_index += 1
    end

    book.write xls_report
    xls_report.string
  end

  def cache_with_mtime(pagename)
    haml_path = File.join(settings.views, "#{pagename}.haml")
    cache_with_custom_defined([File.mtime(haml_path)])
  end
end
