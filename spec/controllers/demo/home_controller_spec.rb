# encoding:utf-8
require File.expand_path '../../../spec_helper.rb', __FILE__

describe Demo::HomeController do
  it 'should ok when view home page' do
    get demo_path('/')
    expect(last_response).to be_ok

    visit demo_path('/')
    expect(page.title).to eql('实验室 | SOLife')
  end
end
