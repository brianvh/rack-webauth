$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'rack/request'

require 'configuration'
require 'ticket'
require 'user'

module Rack
  module Webauth

    # The Authenticator class is actual middleware class. It's initialized by the
    #
    #   use Rack::Webauth
    #
    # method call, which places an Authenticator instance into the middleware stack.
    #
    # You can also send Configuration commands by passing a block to the "use" helper:
    #
    #   use Rack::Webauth do
    #     set_application 'My Cool Rack App'
    #     set_url 'http://mycoolrackapp.com/'
    #   end
    #
    class Authenticator
      attr_reader :request, :session, :ticket

      # We cache the app that we will use to call down the stack. We also setup our
      # Configuration class, with any options passed into the block in the use helper.
      def initialize(app, &options)
        @app = app
        Rack::Webauth::Configuration.options(&options)
      end
      
      # First we setup our reader attributes, which are used by the rest of the methods.
      # Then we check for a ticket in the inbound request. If it's present, we branch off
      # to complete the authentication process.
      #
      # If not, we send the request down through the rest of the stack, to the application,
      # catching the response, coming back up the chain. We then hand that response off for
      # post processing.
      def call(env)
        @request = Rack::Request.new(env)
        raise "Rack::Webauth requires Rack::Session." if env["rack.session"].nil?
        @session = request.session[:webauth] ||= {}
        @ticket = request.params['ticket']
        if ticket?
          complete
        else
          status, headers, body = @app.call(env)
          process(status, headers, body)
        end
      end

      private

      # Is there a ticket in the request?
      def ticket?
        !ticket.nil?
      end

      # Complete the Webauth authentication process, by grabbing the ticket and submitting
      # it for verification. If verification is successful, we place the authenticated user
      # into session[:webauth][:user] and redirect back to the current URL after we remove
      # the ticket parameter. If verfication fails, we return a 500 error.
      def complete
        unset(:return_url)
        unset(:login)
        ticket_response = Ticket.new(ticket, clean_request_url, config).validate
        if ticket_response.valid?
          set(:user, User.new(ticket_response.attributes))
          redirect_to(clean_request_url)
        else
          error_500(ticket_response.error)
        end
      end

      # The process method is called, by the Middleware, after the app response has been
      # returned. Here, we check the various states present in the session to determine if
      # any further processing is needed. We either return the request, start the logout
      # process, or start the login process.
      def process(status, headers, body)
        case true
          when set?(:logout) # user is logging out
            unset(:logout)
            unset(:user)
            process_logout
          when set?(:user) # user is logged in
            [status, headers, body]
          when (status == 401 or set?(:login)) # user is logging in
            process_login
        else # We return all other responses
          [status, headers, body]
        end
      end

      # Here we handle the login process, when the correct session value is set, or the
      # outbound response has a 401 status. We either redirect to the Webauth login URL,
      # or to a local login page, if that's been configured. If we are coming from the local
      # page, redirect to the Webauth login URL.
      def process_login
        set_return_url
        unset(:login)
        # Assume we're redirecting to the Webauth login URL
        location_url = config.login_url(return_url)
        case true
          when set?(:local_login) # already been to the local login page
            unset(:local_login)
          when !config.local_login.nil? # set our location to the local login URL
            set(:local_login, true)
            location_url = local_url('login')
        end
        redirect_to(location_url)
      end
      
      # Handling the logout process is nearly identical to the login process, including
      # specifing a local logout page. The only difference is we delete the :webauth
      # session object, before we redirect to the Webauth logout URL.
      def process_logout
        location_url = config.logout_url
        case true # look for local_logout settings
          when set?(:local_logout)
            request.session.delete(:webauth)
          when !config.local_logout.nil?
            set(:local_logout, true)
            location_url = local_url('logout')
        else
          request.session.delete(:webauth)
        end
        redirect_to(location_url)
      end

      # Helper method for generating the local login/logout URL
      def local_url(login_logout)
        "#{request.scheme}://#{request.host}#{config.send('local_' + login_logout)}"
      end

      # Set a key/value pair into our session sub-hash
      def set(key, val)
        session[key.to_sym] = val
      end

      # Is this key currently set in our session sub-hash
      def set?(key)
        !session[key.to_sym].nil?
      end

      # Remove this key from our session sub-hash
      def unset(key)
        session.delete(key.to_sym)
      end

      # Custom setter for the URL that we return to, after going through the Webauth
      # login step. We don't cache the URL of the local login page.
      def set_return_url
        unless (set?(:return_url) and set?(:local_login))
          session[:return_url] = clean_request_url
        end
      end

      # Custom getter for the cached return URL
      def return_url
        session[:return_url]
      end

      # Helper method for building a redirect response
      def redirect_to(location)
        [ 302, {'Location' => location}, ['']]
      end

      # Helper method for building a 500 Error response.
      def error_500(msg="")
        [
          500,
          {'Content-Type' => 'text/html'},
          ["<html>\n<head><title>Rack::Webauth Error</title></head>\n" +
            "<body><h1>Rack::Webauth Error</h1>\n#{msg}\n</body>\n</html"]
        ]
      end

      # Helper method for accssing our app's configuration
      def config
        Rack::Webauth::Configuration.options
      end

      # Helper method for returning the request URL with any ticket parameter removed
      def clean_request_url
        @clean_request_url ||= request.url.sub(/[\?&]ticket=[^\?&]+/, '')
      end
    end

  end
end
