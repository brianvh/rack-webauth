require 'rubygems'
require 'rack'
require 'rack/request'

require '../../lib/rack/webauth'

use Rack::Session::Cookie
use Rack::Webauth do
  set_application 'My Rack Middleware'
  set_url 'http://rack-app.local/'
  set_local_login '/login'
end

app = proc do |env|
  @request = Rack::Request.new(env)
  extend Rack::Webauth::Helpers
  case @request.path
    when '/'
      [200, { "Content-Type" => "text/plain" }, [@request.session.inspect]]
    when '/blocked'
      login_required
      [200, { "Content-Type" => "text/plain" }, [@request.session[:webauth].inspect]]
    when '/login'
      if @request.get?
        [200, { "Content-Type" => "text/html" }, 
          ["<html>\n<head><title>Login Test</title></head>\n" +
            "<body><h1>Login Test</h1>\n<form action=\"/login\" method=\"post\">\n" +
            "<input type=\"submit\"></form></body>\n</html"]]
      else
        login!
        [200, { "Content-Type" => "text/plain" }, ['']]
      end
    when '/logout'
      logout!
      [200, { "Content-Type" => "text/plain" }, [@request.session.inspect]]
    when '/favicon.ico'
      [200, { "Content-Type" => "text/plain" }, ['']]
  end
end

run app
