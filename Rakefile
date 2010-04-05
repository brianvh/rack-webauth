require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/rack/webauth'
require './lib/rack/webauth/version'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'rack-webauth' do
  self.developer 'Brian V. Hughes', 'brianvh@dartmouth.edu'
  self.version    = Rack::Webauth::VERSION
  self.extra_deps = [['nokogiri','>= 1.2.1'], ['rack','>= 1.1.0']]

end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
