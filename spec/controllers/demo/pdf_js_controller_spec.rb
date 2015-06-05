#encoding:utf-8
require File.expand_path "../../../spec_helper.rb", __FILE__

describe "Demo::PdfJSController" do
  it "page index should show successfully" do
    get "/demo/pdfjs"

    expect(last_response).to be_ok
  end
end