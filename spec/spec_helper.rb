$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'spec'
require 'spec/autorun'

require 'rack/mock'
require 'rack/webauth'
require 'fakeweb'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

Spec::Runner.configure do |config|
  
end
