# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'hsm/version'

Gem::Specification.new do |gem|
  gem.name = 'hsm'
  gem.version = HSM::VERSION
  gem.summary = 'Hierarchical Statemachine'
  gem.authors = ['artcom']
  gem.email = 'info@artcom.de'
  gem.homepage = 'http://www.artcom.de'

  gem.files = Dir['lib/hsm.rb',
                  'lib/hsm/**/*']
  gem.test_files = Dir['spec/**/*', 'Rakefile', 'lib/tasks/**/*'] - Dir['spec/reports/*']
  gem.require_paths = ['lib']

  %w().each do |dep|
    gem.add_runtime_dependency(dep)
  end

  %w(command ci_reporter geminabox-rake chromatic guard-rspec
     simplecov-rcov yard guard-bundler guard-rubocop guard-shell rubocop-checkstyle_formatter).each do |dep|
    gem.add_development_dependency(dep)
  end
end
