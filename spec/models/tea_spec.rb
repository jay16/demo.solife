#encoding:utf-8
require File.expand_path '../../spec_helper.rb', __FILE__

describe Tea do
  context "validations" do
    it { should validatef :name }
    it { should validate_presence_of :price }
  end

  context "associations" do
    #it { should belong_to :menu }
  end

  #context "#name" do 
  #  let(:name) {"fish"}
  #  let(:item) {MenuItem.new(name: name)}
  #  it "returns the name" do
  #    expect(item.name).to eq "fish"
  #  end
  #end
end
