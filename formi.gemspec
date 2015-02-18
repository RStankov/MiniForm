# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'formi/version'

Gem::Specification.new do |spec|
  spec.name          = 'formi'
  spec.version       = Formi::VERSION
  spec.authors       = ['Radoslav Stankov']
  spec.email         = ['rstankov@gmail.com']
  spec.description   = 'Search object DSL'
  spec.summary       = 'Provides DSL for creating search objects'
  spec.homepage      = 'https://github.com/RStankov/formi'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(spec)\//)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.14'
  spec.add_development_dependency 'rspec-mocks', '>= 2.12.3'
  spec.add_development_dependency 'activerecord', '>= 3.0.0'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'will_paginate'
  spec.add_development_dependency 'kaminari'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
end
