module Rack
  module Webauth

    # The basic, Rack helper methods for interacting with the Webauth middleware. You
    # need to: extend Rack::Webauth::Helpers inside your proc do |env| block. This
    # module also requires that you set: @request = Rack::Request.new(env), before you
    # can use any of the helper methods. All of these methods interface with the session.
    module Helpers

      def login_required
        if !logged_in?
          webauth[:login] = true
        end
      end

      def logged_in?
        !webauth[:user].nil?
      end

      def login!
        webauth[:login] = true
      end

      def logout!
        webauth[:logout] = true
      end

      def webauth_user
        webauth[:user]
      end

      private

      def webauth
        self.respond_to?(:session) ? session[:webauth] : @request.session[:webauth]
      end

    end
  end
end
