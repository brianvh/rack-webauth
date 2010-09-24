require File.dirname(__FILE__) + '/spec_helper.rb'

module Rack ; module Webauth
  describe Authenticator do

    before(:each) do
      @auth = Authenticator.new(app)
    end

    describe "basic operation" do
      
      it "should return a normal response from a standard call" do
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
    end

    def app
      proc do |env|
        request = Rack::Request.new(env)
        case request.path
          when '/'
            [200, { "Content-Type" => "text/plain" }, [request.session.inspect]]
          when '/login'
            env['rack.session'][:webauth][:login] = true
            [200, { "Content-Type" => "text/plain" }, [request.session.inspect]]
          when '/logout'
            env['rack.session'][:webauth][:logout] = true
            [200, { "Content-Type" => "text/plain" }, [request.session.inspect]]
        end
      end
    end

  end

end ; end
