$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'vcr'
require 'vcr/api'
require 'vcr/test_frameworks/rspec'

RSpec.configure do |c|
  # destroy the api registry before each test
  c.before(:each) do
    VCR.configuration.api_registry.instance_variable_set(:@registry, Set.new)
  end

  VCR.configure do |vcr|
    vcr.cassette_library_dir = "tmp"
    vcr.hook_into :faraday # or :fakeweb
    vcr.debug_logger = STDOUT
    vcr.configure_rspec_metadata!
  end
end
