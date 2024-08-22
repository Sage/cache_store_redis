require 'simplecov'
SimpleCov.start do
  add_filter 'spec/'
end

require 'timecop'
require 'pry'
require 'pry-byebug' unless RUBY_PLATFORM == 'java'
require_relative 'test_object'
require_relative '../lib/cache_store_redis'

Timecop.safe_mode = true

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
