$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'net/https'
require 'rubygems'
require 'rack/utils'
require 'rack/request'

module Rack ; module Webauth

  # Our custom Request class. Inherited from Rack::Request, we extend the base class
  # with the smarts to handle the authentication tickets that our app receives from
  # the Webauth server. When processed, our class provides the attributes for the
  # authenticated user. It also constructs good URLs for some of our redirects.
  #
  class Request < Rack::Request

    attr_reader :config

    def initialize(env, config)
      super(env)
      @config = config
    end
    
  end

end ; end