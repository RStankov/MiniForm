require 'bundler/setup'

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end

require 'formi'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end
