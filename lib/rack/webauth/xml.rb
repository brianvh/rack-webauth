$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'nokogiri'

module Rack ; module Webauth

  class XML < Nokogiri::XML::Document
    attr_reader :attributes

    class << self
      def parse(xml_text)
        xml = super clean_xml(xml_text)
        if xml.valid?
          xml.auth_success? ? xml.gather_attributes : xml.auth_error
        else
          xml.invalid
        end
        xml
      end

      def clean_xml(xml_text)
        xml_text.gsub(/^[\t ]*/, '').gsub(/\n/, '')
      end
    end

    def valid?
      root.name == 'serviceResponse'
    end

    def auth_success?
      root.child.name == 'authenticationSuccess'
    end

    def gather_attributes
      @attributes = {}
      root.child.children.each do |child|
        next unless child.attributes == {} # we only want the standard elements and their content
        @attributes[child.name.downcase.to_sym] = child.content
      end
    end

  end

end ; end
