#encoding:utf-8
require File.expand_path "../../../spec_helper.rb", __FILE__

describe "Demo::HomeController" do

  it "page index should show successfully" do
    get "/demo"

    expect(last_response).to be_ok

    visit "/demo"

    expect(page).to have_title("SOLife | 实验室")
  end
end