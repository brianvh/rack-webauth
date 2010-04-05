$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'rack/request'

require 'configuration'
require 'ticket'
require 'user'

module Rack
  module Webauth

    class Authenticator
      attr_reader :request, :session, :ticket

      def initialize(env)
        @request = Rack::Request.new(env)
        raise "Rack::Webauth requires Rack::Session." if env["rack.session"].nil?
        @session = request.session[:webauth] ||= {}
        @ticket = request.params['ticket']
      end

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

      private

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

      def local_url(login_logout)
        "#{request.scheme}://#{request.host}#{config.send('local_' + login_logout)}"
      end

      def set(id, val)
        session[id.to_sym] = val
      end

      def set?(id)
        !session[id.to_sym].nil?
      end
      
      def unset(id)
        session.delete(id.to_sym)
      end

      def return_url
        session[:return_url]
      end
      
      def set_return_url
        unless (set?(:return_url) and set?(:local_login))
          session[:return_url] = clean_request_url
        end
      end
      
      def redirect_to(location)
        [ 302, {'Location' => location}, ['']]
      end
      
      def error_500(msg="")
        [
          500,
          {'Content-Type' => 'text/html'},
          ["<html>\n<head><title>Rack::Webauth Error</title></head>\n" +
            "<body><h1>Rack::Webauth Error</h1>\n#{msg}\n</body>\n</html"]
        ]
      end

      def config
        Rack::Webauth::Configuration.options
      end

      def clean_request_url
        @clean_request_url ||= request.url.sub(/[\?&]ticket=[^\?&]+/, '')
      end

    end

  end
end
