#encoding:utf-8
require File.expand_path '../../spec_helper.rb', __FILE__

describe "HomeController" do

  it "page index should show normally." do
    get "/"

    expect(last_response.status).to be(200)

    visit "/"

    expect(page.title).to include("SOLife")
    { "首页" => "/",
      "关于" => "/about",
      "注册" => "/users/register",
      "登陆" => "/users/login"
    }.each_pair do |link_text, href_url|
      expect(page).to have_css("a", text: link_text)
      expect(page.find_link(link_text)[:href]).to eq(href_url)
    end
  end
end
