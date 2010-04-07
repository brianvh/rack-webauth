# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Normally, this would be handled with: config.gem 'rack-webauth, :lib => 'rack/webauth'
require "#{RAILS_ROOT}/../../lib/rack/webauth"

Rails::Initializer.run do |config|

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  config.middleware.use Rack::Webauth do
    set_application 'Rack::Webauth on Rails'
    set_url 'http://rails-app.local/'
    set_local_login '/login'
  end

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

end