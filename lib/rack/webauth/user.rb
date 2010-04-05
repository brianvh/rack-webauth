$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Rack
  module Webauth

    # Container class for verified Webauth (CAS) User. Takes all fields contained in the Response
    # object and provides dynamic accessor methods for them, as well as a [] accessor method for
    # those fields whose name might be a Ruby reserved word.
    class User

      def initialize(cas_data = {})
        @fields = cas_data == {} ? nil : cas_data

        # This is a stopgap condition, to set the realm field. This condition will be removed once
        # the current release of the Webauth server correctly returns realm as a user field.
        if @fields and @fields[:realm].nil?
          @fields[:realm] = @fields[:user].split(/@/)[1]
          @fields.delete(:user) # remove the user field, which is now redundant.
        end
      end
      
      # Inspection string for instances of the class

      def inspect
        attrib_inspect = @fields.inject("") do |attr_string, pair|
          key,value = pair
          attr_string << "#{key}=\"#{value}\", "
        end
        "<#{self.class} #{attrib_inspect.rstrip.chomp(',')}>"
      end

      # Generic Hash-style accessor method. Provides access to entries in the fields hash when
      # the name of the field is a reserved word in Ruby. Allows for field names supplied as
      # either Strings or Symbols.

      def [](field)
        return_field(field)
      end

      private

      # Handles all dynamic accessor methods for the User instance. This is based on the
      # field accessor methods from Rails ActiveRecord. Fields can be directly accessed on
      # the Profile object, either for purposes of returning their value or, if the field name
      # is requested with a '?' on the end, a true/false is returned based on the existence of
      # the named field in User instance.

      def method_missing(method_id)
        attrib_name = method_id.to_s
        return @fields.has_key?(attrib_name.chop.to_sym) if attrib_name[-1, 1] == '?'
        return_field(method_id)
      end

      # Private method, used by the [] method and the dynamic accessors. It will return the value
      # of the named field, or it will raise a FieldNotFound error if the field isn't part of the
      # current Profile.

      def return_field(field)
        field = field.to_sym
        return @fields[field] if @fields.has_key?(field)
        raise "Field #{field} not found."
      end
      
    end

  end
end