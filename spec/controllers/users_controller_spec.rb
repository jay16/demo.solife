#encoding:utf-8
require File.expand_path '../../spec_helper.rb', __FILE__

describe "UsersController" do
  it "default controls state when Get /users/login" do
    get "/users/login"

    expect(last_response).to be_ok

    visit "/users/login"

    expect(page.title).to include("SOLife")
    expect(page).to have_css("h1", text: "登录")
    expect(page.find_field("user[email]").text).to be_empty
    expect(page.find_field("user[password]").text).to be_empty
    expect(page.find_button("提交").disabled?).to_not be_true
  end

  it "should redirect /account when login successfully." do
    visit "/"

    click_link("注册")

    expect(page.current_path).to eq("/users/register")
    expect(page).to have_content("注册")
    within("#registerForm") do
      fill_in "user[name]", with: "test"
      fill_in "user[email]", with: "admin@rspec.com"
      fill_in "user[password]", with: "password"
      fill_in "user[confirm_password]", with: "password"
      click_button("提交")
    end
    expect(page).to have_content("注册成功，请登录.")

    expect(page.current_path).to eq("/users/login")
    expect(page).to have_content("登录")
    within("#loginForm") do
      fill_in "user[email]", with: "admin@rspec.com"
      fill_in "user[password]", with: "password"
      click_button("提交")
    end

    expect(page.current_path).to eq("/account")
    expect(page).to have_content("登录成功")
    #save_and_open_page("./page.html")

    # page.execute_script("window.App.removeGlyphicon()")
    #<a href="/cpanel">
    #  <i class="glyphicon glyphicon-wrench"></i>
    #  后台管理
    #</a>

    page.find_by_id("backgroundControl").click
    expect(page.current_path).to eq("/cpanel")


    page.find_by_id("forheadControl").click
    expect(page.current_path).to eq("/account")
  end
end
