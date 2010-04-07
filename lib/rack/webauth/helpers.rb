module Rack
  module Webauth

    # The basic, Rack helper methods for interacting with the Webauth middleware. You
    # need to: extend Rack::Webauth::Helpers inside your proc do |env| block. This
    # module also requires that you set: @request = Rack::Request.new(env), before you
    # can use any of the helper methods. All of these methods interface with the session.
    module Helpers

      def login_required
        if !logged_in?
          @request.session[:webauth][:login] = true
        end
      end

      def logged_in?
        !webauth_user.nil?
      end

      def login!
        @request.session[:webauth][:login] = true
      end

      def logout!
        @request.session[:webauth][:logout] = true
      end

      private

      def webauth_user
        @request.session[:webauth][:user]
      end

    end
  end
end
