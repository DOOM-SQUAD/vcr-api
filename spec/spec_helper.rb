$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'vcr'
require 'vcr/api'
require 'vcr/test_frameworks/rspec'
require 'capybara'
require 'capybara/rspec'
require 'webrick'
require 'simplecov'

module ListenOnPort
  def listen_on_port?(port)
    `lsof -i :#{port}`
    $? == 0
  end
end

SimpleCov.start

RSpec.configure do |c|
  # destroy the api registry before each test
  c.before(:each) do
    VCR.configuration.api_registry.instance_variable_set(:@registry, Set.new)
  end

  VCR.configure do |vcr|
    vcr.cassette_library_dir = "tmp"
    vcr.configure_rspec_metadata!
    vcr.hook_into :faraday
    # you're probably going to need this.
    # vcr.debug_logger = STDOUT
  end

  c.include ListenOnPort, :server

  c.before(:all, :server) do
    @server = WEBrick::HTTPServer.new(
      Port:       9293,
      Logger:     WEBrick::Log.new('/dev/null'),
      AccessLog:  WEBrick::Log.new('/dev/null'),
    )

    @server.mount '/', Rack::Handler::WEBrick, lambda {|env|
      [200, {}, ['<html><head></head><body><a href="#">Click here</a></body></html>']]
    }

    @server_thread = Thread.new do
      @server.start
    end

    start_time = Time.now

    while !listen_on_port?(9293) && Time.now < start_time + 1
    end

    raise "Could not start server" if !listen_on_port?(9293)
  end

  c.after(:all, :server) do
    @server_thread.kill if listen_on_port?(9293)
  end
end

RSpec::Matchers.define :include_requests_to_url do |expected|
  match do |actual|
    cassette = YAML.load(File.read(actual))
    cassette['http_interactions'].map { |r| r['request']['uri'] }.grep(expected).any?
  end
end

RSpec::Matchers.define_negated_matcher :not_include_requests_to_url, :include_requests_to_url
