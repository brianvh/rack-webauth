$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'net/https'
require 'rubygems'
require 'rack/utils'

require 'response'

module Rack
  module Webauth

    class Ticket

      attr_reader :ticket, :config, :service_url

      def initialize(ticket, service_url, config)
        @ticket = ticket
        @config = config
        @service_url = service_url
      end

      def validate
        http = Net::HTTP.new(config.server_host, config.server_port)
        http.use_ssl = true if config.server_port == 443
        raw_xml = http.get(validation_request).body
        Response.parse_xml(raw_xml)
      end

      def validate!
        response = validate
        raise response.error unless response.valid?
        response.attributes
      end

      private

        def escape(val)
          Rack::Utils.escape(val)
        end
        
        def validation_request
          "#{config.server_validate}?ticket=#{escape(ticket)}&service=#{escape(service_url)}"
        end

    end
  end
end