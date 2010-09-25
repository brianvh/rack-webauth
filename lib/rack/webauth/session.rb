$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Rack ; module Webauth

  # This is a wrapper class for the env['rack.session'][:webauth] hash, which is
  # where our middleware stores all of it's session data and control messages.
  #
  class Session
    attr_reader :session

    def initialize(request)
      @session = request.session[:webauth] ||= {}
    end

  end

end ; end