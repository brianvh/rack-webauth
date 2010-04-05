$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'nokogiri'

module Rack
  module Webauth

    # Handles the returned XML from the Webauth (or CAS) server, after a call to the
    # server's validate_ticket method. This XML should contain a known structure that
    # the response class can recognize and parse.
    #
    # A Response instance will either be "ok" or not. If it's not "ok", it will have
    # a non-nil error attribute. Otherwise it will have a populated hash of retuned
    # XML attributes. These attributes are usually then parsed by the CAS::Webauth::User
    # class into a User instance.
    #
    # The primary role of this class is to compartmentalize the parsing of the various
    # XML structures that can be returned by a Webauth/CAS server.

    class Response

      attr_reader :attributes, :error, :root, :node

      def initialize( xml_data )
        begin
          xml = Nokogiri::XML(xml_data.gsub(/^[\t ]*/, '').gsub(/\n/, ''))
          @error = nil
          @root = xml.root
          @attributes = {}
        rescue Exception => e
          @error = e
        end
      end

      def valid?
        error.nil?
      end

      # This it the primary interface to this class. It handles the initial construction
      # as well as the post processing to fully parse the XML structure, assuming it matches
      # the known structures returned by Webauth (or CAS) servers. Checks are in to halt all
      # processing once an error has been set, so checking the error attribute for non-nil
      # is how you can determine if the parsing was successful.
      def self.parse_xml(xml_text)
        resp = Response.new(xml_text)
        resp.check_root
        resp.check_node
        resp
      end

      def check_root
        return if error
        self.send(underscore(root.name))
        @error = 'The supplied XML is not from a Webauth server.' if @error == true
      end

      def check_node
        return if error
        self.send(underscore(node.name))
        @error = "The response type #{node.name} is not a standard " +
                  "Webauth server response." if @error == true
      end

      private

      def service_response
        @error = nil
        @node = @root.child
      end

      def authentication_success
        @error = nil
        node.children.each do |ch|
          next unless ch.attributes == {} # we only want the standard elements and their content
          attributes[ch.name.downcase.to_sym] = ch.content
        end
      end

      def authentication_failure
        code = node.attributes["code"]
        msg = node.content
        @error = "#{code.to_s}: #{msg}"
      end

      # When we come across a method/node name from the XML document that doesn't match
      # a private method (i.e. a known process node) we tell the instance we've got
      # an error. This flag is used to 
      def method_missing(method_id)
        @error = true
      end

      def underscore(str)
        str.to_s.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
      end
    end

  end
end