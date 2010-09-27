require File.dirname(__FILE__) + '/spec_helper.rb'

describe Rack::Webauth::Request do
  before(:each) do
    @url = 'http://example.org/'
    @login = '/login'
    @configuration = Rack::Webauth::Configuration.options do |config|
      config.set_url @url
      config.set_local_login @login
    end
  end

  describe "-- from a basic request" do
    before(:each) do
      env = Rack::MockRequest.env_for("/")
      @request = Rack::Webauth::Request.new(env, @configuration)
    end

    it "should create a good Request object" do
      @request.should be_instance_of(Rack::Webauth::Request)
    end

    it "should return a good local login path" do
      @request.local_url('login').should == @url.gsub(/\/$/, '') + @login
    end

    it "should not need to be authenticated" do
      @request.should_not be_auth_needed
    end

    it "should raise an error asked to authenticate" do
      lambda { @request.authenticate! }.should raise_error("Authentication not needed for this request.")
    end
  end

  describe "-- from a request needing authentication" do
    before(:each) do
      @ticket = 'fake-webauth-ticket'
      @user = 'Joe User'
      @uid = 1234
      env = Rack::MockRequest.env_for("/?ticket=#{@ticket}")
      @request = Rack::Webauth::Request.new(env, @configuration)
    end

    it "should need to be authenticated" do
      @request.should be_auth_needed
    end

    it "should have the correct clean URL" do
      @request.clean_url.should == @url
    end

    it "should authenticate a valid, known ticket" do
      webauth_valid_ticket_for(@ticket, @user, @uid)
      @request.authenticate!
      @request.should be_auth_valid
    end

    it "should not authenticate an invalid ticket" do
      webauth_invalid_ticket(@ticket)
      @request.authenticate.should be_false
    end
  end

end

