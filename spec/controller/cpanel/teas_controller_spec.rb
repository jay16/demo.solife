#encoding:utf-8
require File.expand_path "../../../spec_helper.rb", __FILE__

describe "Cpanel::TeasController" do
  describe "should unauthorized without login" do
    it "should be redirect to /cpanel/login when visit /cpanel/teas" do
      get "/cpanel/teas"

      expect(last_response).to_not be_ok
      expect(last_response.status).to be(302)
      expect(last_response).to be_redirect

      follow_redirect!
      expect(last_request.url).to eq(redirect_url("/cpanel/login"))

      expect(last_request.cookies["_login_state"]).to be_nil
      expect(last_request.cookies["_before_login_path"]).to eq(redirect_url("/cpanel/teas"))
    end
  end

  describe "should operation with login successfully" do
    before:all do
      get  "/cpanel/teas"
      post "/cpanel/login", { 
        :name     => Settings.login.name, 
        :password => Settings.login.password
      }

      expect(last_response).to be_redirect
      expect(last_response.status).to be(302)

      follow_redirect!
      expect(last_request.url).to eq(redirect_url("/cpanel/teas"))
    end

    it "should show teas list and contain all operations" do
      get "/cpanel/teas"

      h1 = "商品列表"
      expect(last_response).to be_ok
      expect(last_response.body).to include(h1)

      Tea.all.each do |tea|
        expect(last_response.body).to include(tea.name)
        expect(last_response.body).to include("/cpanel/teas/%d/edit" % tea.id)
        expect(last_response.body).to include("/cpanel/teas/%d/image" % tea.id)
        expect(last_response.body).to include("/cpanel/teas/%d/onsale" % tea.id)
        next unless tea.image
        expect(last_response.body).to include(tea.image)
      end
    end

    it "should show tea's detail when click [view]" do
      pending "no view"
    end

    it "should contain [upate] url when [edit]" do
      tea = Tea.first

      get "/cpanel/teas/%d/edit" % tea.id

      expect(last_response).to be_ok
      expect(last_response.body).to include("/cpanel/teas/%d" % tea.id)
    end

    it "should redirect to teas [list] when submit [update]" do
      tea = Tea.first
      new_name = tea.name + "-post"

      post "/cpanel/teas/%d" % tea.id, { tea: { name: new_name }}

      expect(last_response).to be_redirect
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_request.url).to eq(redirect_url("/cpanel/teas?tea=%d" % tea.id))

      _tea = Tea.first(:id => tea.id)
      expect(_tea.name).to eq(new_name)
      expect(_tea.updated_at.to_s).to be > tea.updated_at.to_s
    end

    it "should toggle [onsale] state when click checkbox" do
      tea = Tea.first

      post "/cpanel/teas/%d/onsale" % tea.id, { status: !(tea.onsale || false) }

      _tea = Tea.first(:id => tea.id)
      expect(_tea.onsale).to_not be(tea.onsale)
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to eq(redirect_url("/cpanel/teas?tea=%d" % _tea.id))

      post "/cpanel/teas/%d/onsale" % tea.id, { status: !(_tea.onsale || false) }

      _tea_ = Tea.first(:id => tea.id)
      expect(_tea_.onsale).to_not be(_tea.onsale)
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to eq(redirect_url("/cpanel/teas?tea=%d" % _tea_.id))
    end

  end
end
