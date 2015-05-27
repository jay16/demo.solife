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

  it "cn-ZH number convert to alabo number" do
  	@td_map = {
	    #1 digit 个
	    '零' => 0,
	    '一' => 1,
	    '二' => 2,
	    '三' => 3,
	    '四' => 4,
	    '五' => 5,
	    '六' => 6,
	    '七' => 7,
	    '八' => 8,
	    '九' => 9,

	    #2 digits 十
	    '十' => 10,
	    '十一' => 11,
	    '二十' => 20,
	    '二十一' => 21,

	    #3 digits 百
	    '一百' => 100,
	    '一百零一' => 101,
	    '一百一十' => 110,
	    '一百二十三' => 123,

	    #4 digits 千
	    '一千' => 1000,
	    '一千零一' => 1001,
	    '一千零一十' => 1010,
	    '一千一百' => 1100,
	    '一千零二十三' => 1023,
	    '一千二百零三' => 1203,
	    '一千二百三十' => 1230,

	    #5 digits 万
	    #@@@@
	    '一万' => 10000,
	    '一万零一' => 10001,
	    '一万零一十' => 10010,
	    '一万零一百' => 10100,
	    '一万一千' => 11000,
	    '一万零一十一' => 10011,
	    '一万零一百零一' => 10101,
	    '一万一千零一' => 11001,
	    '一万零一百一十' => 10110,
	    '一万一千零一十' => 11010,
	    '一万一千一百' => 11100,
	    '一万一千一百一十' => 11110,
	    '一万一千一百零一' => 11101,
	    '一万一千零一十一' => 11011,
	    '一万零一百一十一' => 10111,
	    '一万一千一百一十一' => 11111
	}
	@td_map.each_pair do |key, value|
		expect(key.to_s.cn_convert_num).to eq(value.to_i)
	end
  end
  
end
