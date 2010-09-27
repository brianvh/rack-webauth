$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'net/https'
require 'rubygems'
require 'rack/utils'
require 'rack/request'

require 'response'

module Rack ; module Webauth

  # Our custom Request class. Inherited from Rack::Request, we extend the base class
  # with the smarts to handle the authentication tickets that our app receives from
  # the Webauth server. When processed, our class provides the attributes for the
  # authenticated user. It also constructs good URLs for some of our redirects.
  #
  class Request < Rack::Request

    attr_reader :config, :payload, :clean_url

    def initialize(env, config)
      super(env)
      @config = config
      @payload = nil
      @clean_url = url.sub(/[\?&]ticket=[^\?&]+/, '') # Our URL without a ticket parameter
    end

    # Do we have a request that's looking to be authenticated?
    def auth_needed?
      !params['ticket'].nil?
    end

    # Submit a validate request to the configured Webauth server. Hand the
    # returned XML payload to the Response object, for parsing, and store the
    # result, both for error checking and accessing the user's attributes.
    # Returns true or false, if the parsed payload is valid.
    #
    def authenticate
      if auth_needed?
        http = Net::HTTP.new(config.server_host, config.server_port)
        http.use_ssl = true if config.server_port == 443
        response = http.get(auth_validate_path)
        @payload = Response.parse_xml(response.body)
        payload.valid?
      else
        false
      end
    end

    # Run our authenticate method, but raise an error if the payload isn't valid.
    def authenticate!
      auth_needed? or raise "Authentication not needed for this request."
      authenticate or raise payload.error
    end

    # Is our parsed payload valid?
    def auth_valid?
      !payload.nil? and payload.valid?
    end

    # Helper method for generating good redirect URLs for the local login/logout pages
    def local_url(login_logout)
      "#{scheme}://#{host}#{config.send('local_' + login_logout)}"
    end

    private

    # Convenience getter for constructing the path to validate our authentication ticket
    def auth_validate_path
      "#{config.server_validate}?ticket=#{escape_ticket}&service=#{escape_clean_url}"
    end

    # Private getter method for URL escaped ticket parameter
    def escape_ticket
      escape_param(params['ticket'])
    end

    # Private getter method for URL escaped requested URL
    def escape_clean_url
      escape_param(clean_url)
    end

    # Wrapper method for escaping URL query parameters
    def escape_param(val)
      Rack::Utils.escape(val)
    end
    
  end

end ; end