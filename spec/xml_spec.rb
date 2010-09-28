require File.dirname(__FILE__) + '/spec_helper.rb'

describe Rack::Webauth::XML do

  describe "-- parsing a sucessful webauth payload" do
    before(:each) do
      xml_text = File.read("spec/support/webauth_good_payload.xml")
      @xml = Rack::Webauth::XML.parse(xml_text)
    end

    it "should be a good response" do
      @xml.should be_good_response
    end

    it "should be a successful authentication" do
      @xml.should be_auth_success
    end

    it "should be valid" do
      @xml.should be_valid
    end

    it "should have the correct number of attributes" do
      @xml.attributes.should have(6).items
    end
  end

  describe "-- parsing a failed webauth payload" do
    before(:each) do
      xml_text = File.read("spec/support/webauth_failed_payload.xml")
      @xml = Rack::Webauth::XML.parse(xml_text)
    end

    it "should be a good response" do
      @xml.should be_good_response
    end

    it "should not be a successful authentication" do
      @xml.should_not be_auth_success
    end

    it "should not be valid" do
      @xml.should_not be_valid
    end

  end

  describe "-- parsing a random XML document" do
    before(:each) do
      xml_text = "<xml><document name=\"foo\">Bar!</document></xml>"
      @xml = Rack::Webauth::XML.parse(xml_text)
    end

    it "should not be a good response" do
      @xml.should_not be_good_response
    end

    it "should not be valid" do
      @xml.should_not be_valid
    end

  end

end
