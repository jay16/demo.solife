#encoding: utf-8 
class Demo::PdfJSController < Demo::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/demo/pdf_js"
  set :layout, :"../layouts/layout"

  # get /demo/pdfjs
  get "/" do
    haml :index, layout: settings.layout
  end
 
  # for pdfJS
  get "/:file.pdf" do
    send_file File.join(ENV["APP_ROOT_PATH"], "app/views/demo/pdf_js/iSearch.pdf")
  end
end
