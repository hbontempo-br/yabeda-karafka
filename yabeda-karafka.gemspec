# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yabeda/karafka/version'

Gem::Specification.new do |s|
  s.name = 'yabeda-karafka-2'
  s.version = Yabeda::Karafka::VERSION
  s.summary = 'Monitoring of Karafka operation'
  s.description = 'Extends Yabeda to collect Karafka metrics'
  s.homepage = 'https://github.com/hbontempo-br/yabeda-karafka'
  s.license = 'MIT'
  s.required_ruby_version = Gem::Requirement.new('>= 2.7')

  s.metadata['homepage_uri'] = s.homepage
  s.metadata['source_code_uri'] = s.homepage
  s.metadata['changelog_uri'] = "#{s.homepage}/blob/master/CHANGELOG.md"
  s.metadata['bug_tracker_uri'] = "#{s.homepage}/issues"

  s.authors = ['Henrique Bontempo']
  s.email = 'me@hbontempo.dev'

  s.require_paths = ['lib']
  s.files = Dir['lib/**/*.rb']

  s.add_dependency 'anyway_config', '>= 1.3', '< 3'
  s.add_dependency 'karafka', '~> 2.0'
  s.add_dependency 'yabeda', '~> 0.8'

  s.add_development_dependency 'bundler', '~> 2.0'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.0'
end
