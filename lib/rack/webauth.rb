$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Rack
  module Webauth

    # Load the Rack Middleware interface.
    autoload :Middleware, 'webauth/middleware'
    autoload :Authenticator, 'webauth/authenticator'
    autoload :Configuration, 'webauth/configuration'
    autoload :Ticket, 'webauth/ticket'
    autoload :Response, 'webauth/response'
    autoload :User, 'webauth/user'
    autoload :Helpers, 'webauth/helpers'

    # module Helpers
    #   autoload :Rails, 'webauth/helpers/rails'
    #   autoload :Sintra, 'webauth/helpers/sinatra'
    # end

    def self.new(env, &config)
      Authenticator.new(env, &config)
    end
  end
end