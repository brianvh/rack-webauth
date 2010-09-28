require File.dirname(__FILE__) + '/spec_helper.rb'

describe Rack::Webauth::Session do

  describe "-- created without env['rack.session']" do

    it "should raise an error" do
      env = Rack::MockRequest.env_for('/')
      lambda { Rack::Webauth::Session.new(env)}.should raise_error("Rack::Webauth requires Rack::Session.")
    end

  end

  describe " -- created with env['rack.session']" do
    before(:each) do
      @env = Rack::MockRequest.env_for('/', 'rack.session' => {})
      @session = Rack::Webauth::Session.new(@env)
    end

    it "should return an empty hash" do
      @session.inspect.should == {}
    end

    it "should set a :webauth sub-hash in env['rack.session']" do
      @env['rack.session'][:webauth].should == {}
    end

    it "should set, and retrieve, the return URL" do
      @session.return = 'http://example.com/'
      @session.return.should == 'http://example.com/'
    end

    it "return true when questioned about the login flag, when set" do
      @session.set(:login)
      @session.should be_login
    end

    it "should return false when questioned about logout, when not set" do
      @session.should_not be_logout
    end

    it "should raise an error when 'set' method is called on a bad attribute" do
      attrib = :foo
      lambda { @session.set(attrib) }.should raise_error("Boolean setting not valid for #{attrib.inspect}")
    end

    describe " -- clearing settings" do
      before(:each) do
        @session.user = "Foo"
      end

      it "should have a user setting" do
        @session.should be_user
      end

      it "should clear the user setting" do
        @session.clear(:user)
        @session.should_not be_user
      end
      
      it "should clear the entire :webauth sub-hash on 'clear_all" do
        @session.clear_all
        @session.inspect.should == {}
        @env['rack.session'][:webauth].should be_nil
      end
    end

  end

end
