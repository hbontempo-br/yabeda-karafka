# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in yabeda-karafka.gemspec
gemspec

karafka_version = ENV.fetch('KARAFKA_VERSION', '~> 2.4')
case karafka_version
when 'HEAD'
  gem 'karafka', github: 'https://github.com/karafka/karafka.git'
else
  gem 'karafka', karafka_version
end

group :development, :test do
  gem 'pry'
  gem 'pry-byebug', platform: :mri

  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'yabeda', github: 'yabeda-rb/yabeda', branch: 'master' # For RSpec matchers
end
