require File.dirname(__FILE__) + '/spec_helper.rb'

describe Rack::Webauth::Configuration do

  describe "-- working with the Base class" do
    before(:each) do
      @config = Rack::Webauth::Configuration::Base.new()
    end

    it "should be a Base class object" do
      @config.should be_instance_of(Rack::Webauth::Configuration::Base)
    end

    it "should set the URL attribute" do
      url = "http://example.com/"
      @config.set_url url
      @config.url.should == url
    end

    it "should raise an error on a bad set_ attribute" do
      lambda { @config.set_foo("bar") }.should raise_error(/Undefined setter/)
    end

    it "should raise a standard No Method error on an unknown attribute" do
      lambda { @config.foo("bar") }.should raise_error(NoMethodError)
    end
  end

  describe "-- working with the Single class" do
    before(:each) do
      @config = Rack::Webauth::Configuration.options
    end

    it "should be a Single class object" do
      @config.should be_instance_of(Rack::Webauth::Configuration::Single)
    end

    describe "-- setting values in a block" do
      before(:each) do
        @url = "http://example.com/"
        Rack::Webauth::Configuration.options do |config|
          config.set_url @url
        end
      end

      it "should have the correct URL attribute" do
        @config.url.should == @url
      end
    end
  end
end