$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Rack
  module Webauth

    # Load the Rack Middleware interface.
    autoload :Middleware, 'webauth/middleware'
    autoload :Helpers, 'webauth/helpers'

    module Helpers
      autoload :Rails, 'webauth/helpers/rails'
      autoload :Sintra, 'webauth/helpers/sinatra'
    end

  end
end