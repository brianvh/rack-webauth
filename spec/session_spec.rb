require File.dirname(__FILE__) + '/spec_helper.rb'

describe Rack::Webauth::Session do

  it "should raise an error if rack.session isn't set" do
    env = Rack::MockRequest.env_for("/")
    lambda { Rack::Webauth::Session.new(env)}.should raise_error("Rack::Webauth requires Rack::Session.")
  end

end
