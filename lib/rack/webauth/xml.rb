$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'nokogiri'

module Rack ; module Webauth

  class XML < Nokogiri::XML::Document
    attr_reader :attributes

    def self.parse(xml_text)
      xml = super xml_text.gsub(/^[\t ]*/, '').gsub(/\n/, '')
      if xml.good_response?
        xml.auth_success? ? xml.gather_attributes : xml.auth_error
      else
        xml.invalid
      end
      xml
    end

    def valid?
      errors.empty?
    end

    def good_response?
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

    def invalid
      errors << 'The supplied XML is not from a Webauth server.'
    end

    def auth_error
      node = root.child
      errors << "#{node.attributes["code"]}: #{node.attributes["code"]}"
    end

  end

end ; end
