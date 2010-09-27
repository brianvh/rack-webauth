$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Rack ; module Webauth

  # This is a wrapper class for the env['rack.session'][:webauth] hash, which is
  # where our middleware stores all of it's session data and control messages.
  #
  class Session

    def initialize(env_hash)
      @env = env_hash['rack.session']
      raise "Rack::Webauth requires Rack::Session." if @env.nil?
      @session = @env[:webauth] ||= {}
    end

    def inspect
      @session
    end

    def set(name)
      attrib = name.to_sym
      unless booleans.include?(attrib)
        raise "Boolean setting not valid for #{attrib.inspect}"
      end
      send("#{attrib}=", 1)
    end

    def clear(name)
      attrib = name.to_sym
      @session.delete(attrib)
    end

    def clear_all
      @session.clear
      @env.delete(:webauth)
    end

    private

    def attribtues
      [:return, :user, :login, :local_login, :logout, :local_logout]
    end

    def booleans
      [:login, :local_login, :logout, :local_logout]
    end

    def method_missing(method_id, value = nil)
      method_name = method_id.to_s
      attrib = method_name.gsub(/([=\?])$/, '').to_sym
      super unless attribtues.include?(attrib)
      case $1
        when nil
          @session[attrib]
        when '='
          @session[attrib] = value
        when '?'
          @session[attrib].nil? ? false : true
      end
    end
  end

end ; end

