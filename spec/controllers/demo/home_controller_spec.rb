#encoding:utf-8
require File.expand_path "../../../spec_helper.rb", __FILE__

describe "Demo::HomeController" do

  it "page index should show successfully" do
    get "/demo"

    expect(last_response).to be_ok

    visit "/demo"

    expect(page).to have_title("SOLife | 实验室")
  end

  it "page index should respond with what received when post" do
    post "/demo", { "hello" => "world" }.to_json

    expect(JSON.parse(last_response.body)["hello"]).to eq("world")
  end
end