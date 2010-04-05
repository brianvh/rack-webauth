require 'sinatra/base'

module Rack
  module Webauth
    module Helpers

      module Sinatra

        def logged_in?
          session[:webauth]
        end

        def logged_in!
          return validate! if params[:ticket]
          redirect '/session/login' unless logged_in?
        end

        def send_to_login
          redirect 'https://login.dartmouth.edu/cas/login/?service=http://cas-test.local/'
        end

        def send_to_logout

        end

      end

    end
  end
end

