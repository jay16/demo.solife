# encoding:utf-8
require File.expand_path '../../../spec_helper.rb', __FILE__

describe Demo::MoneyBallController do
  it 'should ok when view home page' do
    get demo_path('/ball')
    expect(last_response).to be_ok
    expect(last_response.headers['ETag']).to_not be_empty
    expect(last_response.headers['Last-Modified']).to_not be_empty

    header 'IF-None-Match', last_response.headers['ETag']
    header 'If-Modified-Since', last_response.headers['Last-Modified']
    get demo_path('/ball')
    
    expect(last_response.status).to eq(304)
    expect(last_response.body).to be_empty

    visit demo_path('/ball')
    expect(page.title).to include('台球')
  end
end
