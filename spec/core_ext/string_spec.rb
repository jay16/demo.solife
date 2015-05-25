#encoding:utf-8
require File.expand_path '../../spec_helper.rb', __FILE__

describe "StringExterned" do

  it "consume string parse" do
    str = "测试20元"
    expect(str.process_consume).to eq(["测试(20元)", 20.0])
    str = "测试20元测试30元"
    expect(str.process_consume).to eq(["测试(20元) \n测试(30元)", 50.0])
    str = "测试20元测试30元测试40"
    expect(str.process_consume).to eq(["测试(20元) \n测试(30元) \n测试40", 50.0])
  end
  
end
