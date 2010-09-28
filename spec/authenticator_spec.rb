require File.dirname(__FILE__) + '/spec_helper.rb'

describe Rack::Webauth::Authenticator do

  before(:each) do
    @auth = Rack::Webauth::Authenticator.new(app)
    @url = 'http://example.org/'
    Rack::Webauth::Configuration.options {|config| config.set_url @url}
  end

  describe "-- basic operation" do
    
    it "should raise an error without rack.session" do
      env = Rack::MockRequest.env_for("/")
      lambda { @auth.call(env) }.should raise_error
    end

    it "should return a normal response for a standard call" do
      env = Rack::MockRequest.env_for("/", 'rack.session' => {})
      response = Rack::MockResponse.new(*@auth.call(env))
      response.status.should == 200
    end

    it "should redirect to the login page when a login is requested" do
      env = Rack::MockRequest.env_for('/login', 'rack.session' => {})
      response = Rack::MockResponse.new(*@auth.call(env))
      response.status.should == 302
      response.headers['location'].should match(/login\.dartmouth\.edu\/cas\/login/)
    end

    it "should redirect to the logout page when a logout is requested" do
      env = Rack::MockRequest.env_for('/logout', 'rack.session' => {})
      response = Rack::MockResponse.new(*@auth.call(env))
      response.status.should == 302
      response.headers['location'].should match(/login\.dartmouth\.edu\/logout\.php/)
    end

    describe "-- with local login and logout pages" do
      before(:each) do
        @login_path = '/login'
        @logout_path = '/logout'
        Rack::Webauth::Configuration.options do |config|
          config.set_local_login @login_path
          config.set_local_logout @logout_path
        end
      end

      it "should redirect to the login path, when login is requested" do
        env = Rack::MockRequest.env_for("/", 'rack.session' => {:webauth => {:login => 1}})
        response = Rack::MockResponse.new(*@auth.call(env))
        response.status.should == 302
        response.headers['location'].should == @url.gsub(/\/$/, '') + @login_path
      end

      it "should redirect to the logout path, when logut is requested" do
        env = Rack::MockRequest.env_for("/", 'rack.session' => {:webauth => {:logout => 1}})
        response = Rack::MockResponse.new(*@auth.call(env))
        response.status.should == 302
        response.headers['location'].should == @url.gsub(/\/$/, '') + @logout_path
      end
    end
  end

  describe "-- login with a valid ticket" do
    before(:each) do
      ticket = 'fake-webauth-ticket'
      webauth_valid_ticket_for(ticket, 'Joe User', 1234)
      @env = Rack::MockRequest.env_for("/?ticket=#{ticket}", 'rack.session' => {})
      @response = Rack::MockResponse.new(*@auth.call(@env))
    end

    it "should return a 302 redirect" do
      @response.status.should == 302
    end

    it "should redirect to the application's URL" do
      @response.headers['location'].should == @url
    end

    it "should have a :user entry in the :weauth session sub-hash" do
      @env['rack.session'][:webauth][:user].should_not be_nil
    end
  end

  describe "-- login with an invalid ticket" do
    before(:each) do
      ticket = 'fake-webauth-ticket'
      webauth_invalid_ticket(ticket)
      @env = Rack::MockRequest.env_for("/?ticket=#{ticket}", 'rack.session' => {})
      @response = Rack::MockResponse.new(*@auth.call(@env))
    end

    it "should return a 500 error" do
      @response.status.should == 500
    end

    it "should identify the ticket as invalid" do
      @response.body.should match(/INVALID_TICKET/)
    end
  end

  def app
    proc do |env|
      request = Rack::Request.new(env)
      case request.path
        when '/'
          [200, { "Content-Type" => "text/plain" }, [request.session.inspect]]
        when '/login'
          env['rack.session'][:webauth][:login] = 1
          [200, { "Content-Type" => "text/plain" }, [request.session.inspect]]
        when '/logout'
          env['rack.session'][:webauth][:logout] = 1
          [200, { "Content-Type" => "text/plain" }, [request.session.inspect]]
      end
    end
  end

end
