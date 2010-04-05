$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'singleton'
require 'rubygems'
require 'rack/utils'

module Rack
  module Webauth

    class Configuration

      include Singleton

      attr_reader :server_host, :server_port, :server_login, :server_logout, :server_validate
      attr_reader :application, :url, :local_login, :local_logout

      def initialize
        @server_host = 'login.dartmouth.edu'
        @server_port = 443
        @server_login = '/cas/login'
        @server_logout = '/logout.php'
        @server_validate = '/cas/serviceValidate'
        @application = 'My Rack Application'
        @url = @local_login = @local_logout = nil
      end

      def login_url(return_url)
        "https://#{server_host}#{server_login}?service=#{escape(return_url)}"
      end

      def logout_url
        "https://#{server_host}#{server_logout}?app=#{escape(application)}&url=#{escape(url)}"
      end

      def self.options(&block)
        config = Configuration.instance
        if block_given?
          block.arity < 1 ? config.instance_eval(&block) : block.call(config)
        end
        config
      end

      private

        def escape(val)
          Rack::Utils.escape(val)
        end

        # Handle all of the "set_" method calls, for setting our configuration instance variables
        def method_missing(setter, value)
          case setter.to_s
          when /^set_(.+)/
            variable_name = "@#{$1}"
            if instance_variable_defined?(variable_name)
              instance_variable_set(variable_name, value)
            else
              raise NoMethodError.new("Undefined setter '#{setter.to_s}' for #{self.class}.")
            end
          else
            super
          end
        end
    end

  end
end
