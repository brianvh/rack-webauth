$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'configuration'
require 'authenticator'

module Rack
  module Webauth

    # The middleware class is the main hook into Rack::Webauth. You specify it with a:
    #   use Rack::Webauth::Middleware
    #
    # You can also send Configuration commands to Rack::Webauth, by passing a block on
    # the "use" line:
    #
    #   use Rack::Webauth::Middleware do
    #     set_application 'My Cool Rack App'
    #     set_url 'http://mycoolrackapp.com/'
    #   end
    #
    # The Middleware dispatches to the Authenticator, when there's a need to interact
    # with the Webauth server. It does this both before and after the @app.call(env),
    # first to check for a Webauth ticket, which indicates the browser has just returned
    # from the authentication step and needs to be verified. The authentiactor also runs
    # a post process on the outgoing response to see if a :login or :logout flag is set.
    class Middleware
      def initialize(app, &options)
        @app = app
        Rack::Webauth::Configuration.options(&options)
      end
      
      def call(env)
        authenticator = Authenticator.new(env)
        if authenticator.ticket?
          authenticator.complete
        else
          status, headers, body = @app.call(env)
          authenticator.process(status, headers, body)
        end
      end
    end

  end
end
