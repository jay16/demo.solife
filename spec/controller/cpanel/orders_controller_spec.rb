#encoding:utf-8
require File.expand_path "../../../spec_helper.rb", __FILE__

describe "Cpanel::OrdersController" do
  describe "should unauthorized without login" do
    it "should be redirect to /cpanel/login when visit /cpanel/orders" do
      get "/cpanel/orders"

      expect(last_response).to_not be_ok
      expect(last_response.status).to be(302)
      expect(last_response).to be_redirect

      follow_redirect!
      expect(last_request.url).to eq(redirect_url("/cpanel/login"))


      expect(last_request.cookies["_login_state"]).to be_nil
      expect(last_request.cookies["_before_login_path"]).to eq(redirect_url("/cpanel/orders"))
    end
  end

  describe "should operation with login successfully" do
    before:all do
      get  "/cpanel/orders"
      post "/cpanel/login", { 
        :name     => Settings.login.name, 
        :password => Settings.login.password
      }

      expect(last_response).to be_redirect
      expect(last_response.status).to be(302)

      follow_redirect!
      expect(last_request.url).to eq(redirect_url("/cpanel/orders"))
    end
    it "should show orders list when visit index" do
      get "/cpanel/orders"

      h1 = "订单列表"
      expect(last_response).to be_ok
      expect(last_response.body).to include(h1)
    end
  end
end
