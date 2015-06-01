#encoding:utf-8
require File.expand_path '../../spec_helper.rb', __FILE__

describe "HomeController" do

  it "public pages" do
    get "/"
    expect(last_response.status).to be(200)
  end
end
