# frozen_string_literal: true

require './lib/simmer/version'

Gem::Specification.new do |s|
  s.name        = 'simmer'
  s.version     = Simmer::VERSION
  s.summary     = 'Pentaho Data Integration Automated Test Suite'

  s.description = <<-DESCRIPTION
    Provides a harness for testing Pentaho Data Integration jobs and transformations.
  DESCRIPTION

  s.authors     = ['Matthew Ruggio']
  s.email       = ['mruggio@bluemarblepayroll.com']
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir      = 'exe'
  s.executables = %w[simmer]
  s.homepage    = 'https://github.com/bluemarblepayroll/simmer'
  s.license     = 'MIT'
  s.metadata    = {
    'bug_tracker_uri' => 'https://github.com/bluemarblepayroll/simmer/issues',
    'changelog_uri' => 'https://github.com/bluemarblepayroll/simmer/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://www.rubydoc.info/gems/simmer',
    'homepage_uri' => s.homepage,
    'source_code_uri' => s.homepage
  }

  s.required_ruby_version = '>= 2.5'

  s.add_dependency('acts_as_hashable', '~>1')
  s.add_dependency('aws-sdk-s3', '~>1.6')
  s.add_dependency('mysql2', '~>0.5')
  s.add_dependency('objectable', '~>1')
  # TODO: add this back once there is a proper release:
  # s.add_dependency('pdi', '~>2')
  s.add_dependency('stringento', '~>2')

  s.add_development_dependency('guard-rspec', '~>4.7')
  s.add_development_dependency('pry', '~>0')
  s.add_development_dependency('rake', '~> 13')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rubocop', '~>0.79.0')
  s.add_development_dependency('simplecov', '~>0.17.0')
  s.add_development_dependency('simplecov-console', '~>0.6.0')
end
