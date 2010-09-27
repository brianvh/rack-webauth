require File.dirname(__FILE__) + '/spec_helper.rb'

describe Rack::Webauth::XML do

  describe "-- parsing a sucessful webauth payload" do
    before(:each) do
      xml_text = File.read("spec/support/webauth_good_payload.xml")
      @xml = Rack::Webauth::XML.parse(xml_text)
    end

    it "should be a valid response" do
      @xml.should be_valid
    end

    it "should be a successful authentication" do
      @xml.should be_auth_success
    end

    it "should have the correct number of attributes" do
      @xml.attributes.should have(6).items
    end
  end

end
