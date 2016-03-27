# encoding:utf-8
require File.expand_path '../../../spec_helper.rb', __FILE__

describe Demo::MoneyBallController do
  it 'should ok when view home page' do
    get demo_path('/money_ball')
    expect(last_response).to be_ok
  end
end
