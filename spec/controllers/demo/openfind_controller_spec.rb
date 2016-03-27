# encoding:utf-8
require File.expand_path '../../../spec_helper.rb', __FILE__

describe 'Demo::OpendfindController' do
  it 'page index should show successfully' do
    get demo_path('/openfind')

    expect(last_response).to be_ok

    visit demo_path('/openfind')

    expect(page.title).to eql("Openfind电子报 | SOLife")
    expect(page.find_field('members[url]').text).to be_empty
    # expect(page.find_field("input[type=submit]", exact: false).disabled?).to be_truthy
    expect(page.find_field('template[url]').text).to be_empty
    # expect(page.find_by_id('templateSubmit', exact: false).disabled?).to be_truthy
  end

  it "should download zip file when click [名单下载]" do
    # visit demo_path('/openfind')

    # within('#membersForm') do
    #   fill_in 'members[url]', with: "#{Settings.openfind.url}/china/order/show.php"

    #   page.find_field("submit").click
    # end
    # expect(page.response_headers['Content-Type']).to eq('text/csv;charset=utf-8')
    # expect(page.response_headers['Content-Disposition']).to match(/attachment;\s+filename=\"Openfind名单_\d{14}.csv\"/)
  end

  it "should download zip file when click [模板下载]" do
    # visit demo_path('/openfind')

    # within('#templateForm') do
    #   fill_in 'template[url]', with: "#{Settings.openfind.url}/china/epaper/2012_12/"

    #   page.find_field("submit").click
    # end
    # expect(page.response_headers['Content-Type']).to eq('application/zip')
    # expect(page.response_headers['Content-Disposition']).to match(/attachment;\s+filename=\"openfind 电子报模板_\d{14}.zip\"/)
  end
end
