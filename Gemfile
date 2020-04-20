source 'http://rubygems.org'

group :test do
  if puppetversion = ENV['PUPPET_GEM_VERSION']
    gem 'puppet', puppetversion, :require => false
  else
    gem 'puppet', ENV['PUPPET_VERSION'] || '~> 3.8.0'
  end

  # rspec must be v2 for ruby 1.8.7
  if RUBY_VERSION >= '1.8.7' and RUBY_VERSION < '1.9'
    gem 'rspec', '~> 2.0'
  end

  gem 'rake', '~> 12.3', '>= 12.3.3'
  gem 'puppet-lint'
  gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem 'puppet-syntax'
  gem 'puppetlabs_spec_helper'
  gem 'simplecov'
  gem 'metadata-json-lint'
end

group :development do
  gem 'i18n', '0.6.11'
  gem 'lumberjack', '~> 1.0', '>= 1.0.9'
  gem 'minitest', '~> 4.7.5'
  gem 'travis'
  gem 'travis-lint'
  gem 'puppet-blacksmith'  
  gem 'guard-rake'
  gem 'listen', '~> 3.0.0'
end

group :system_tests do
  gem 'dry-inflector', '~> 0.1.1'
  gem 'jwt', '~> 1.5', '>= 1.5.5'
  gem 'signet', '~> 0.9.2'
  gem 'rb-inotify', '~> 0.9.9'  
  gem 'beaker'
  gem 'beaker-rspec'
  gem 'vagrant-wrapper'
end
