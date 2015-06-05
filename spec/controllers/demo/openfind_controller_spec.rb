#encoding:utf-8
require File.expand_path "../../../spec_helper.rb", __FILE__

describe "Demo::OpendfindController" do

  it "page index should show successfully" do
    get "/demo/openfind"

    expect(last_response).to be_ok
    expect(last_response.body).to include("id='memberForm'")

=begin
    visit "/demo/openfind"
 
    File.open("./page.html", "w:utf-8") { |file| file.puts(page.html.to_s) }
    within("form#memberForm") do
      fill_in "url", with: "http://cndemo.openfind.com/china/order/show.php"
    end
    click_button "名单下载"

    expect(last_response.status).to eq(200)
    expect(Digest::MD5.hexdigest(last_response.body)).to eq("md5-value")
=end
  end

end