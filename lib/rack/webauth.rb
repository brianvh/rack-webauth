$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'webauth/user'

module Rack
  module Webauth

    autoload :Authenticator, 'webauth/authenticator'
    autoload :Configuration, 'webauth/configuration'
    autoload :Session, 'webauth/session'
    autoload :Request, 'webauth/request'
    autoload :XML, 'webauth/xml'
    autoload :Helpers, 'webauth/helpers'

    # This is a convenience method on our main module. The Authenticator class is the
    # actual driver for our middleware, but we want to provide an API that allows for:
    #
    #   use Rack::Webauth
    #
    # Following the convention. Our new method returns an instance of the Authenticator,
    # which becomes the target of the "call" method, as our middleware is "used" in the
    # standard request and response call chains.
    def self.new(app, &config)
      Authenticator.new(app, &config)
    end
  end
end
