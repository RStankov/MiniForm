require 'bundler/setup'

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end

require 'form_object'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end
