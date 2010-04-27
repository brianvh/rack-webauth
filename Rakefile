require 'rubygems'
require 'rake'

require 'lib/rack/webauth/version'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'rack-webauth'
    gem.version = Rack::Webauth::VERSION
    gem.summary = %Q{Rack middleware for Webauth authentication.}
    gem.description = %Q{Rack middleware for Webauth authentication. Works with rack, sinatra and rails applications.}
    gem.email = 'brianvh@mac.com'
    gem.homepage = 'http://github.com/brianvh/rack-webauth'
    gem.authors = ['Brian V. Hughes']
    gem.add_dependency('rack', '>= 1.1.0')
    gem.add_dependency('nokogiri', '>= 1.4.1')
    gem.add_development_dependency "rspec", ">= 1.2.9"
  end
  # Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

begin
  require 'reek/adapters/rake_task'
  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new do |t|
    t.verbose = false
  end
rescue LoadError
  task :roodi do
    abort "Roodi is not available. In order to run roodi, you must: sudo gem install roodi"
  end
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rack-webauth #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
