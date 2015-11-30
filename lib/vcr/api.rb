require "vcr/api/version"
require 'forwardable'

require_relative 'api/configuration'
require_relative 'api/request_handler'
require_relative 'api/matcher'
require_relative 'api/rspec_metadata'
require_relative 'api/registry'
require_relative 'api/cassette_name'
require_relative 'api/uri_matcher'
require_relative 'api/expiration_matcher'

module VCR
  class API
    extend Forwardable

    attr_reader :endpoint, :service_name, :expires, :match_on

    def_delegators :endpoint, :host, :port, :scheme, :path

    def initialize(service_name, address, **options)
      @endpoint = URI.parse(address)
      @service_name = service_name
      @expires = options.fetch(:expires, false) || options.fetch(:expired, false)
      @match_on = options.fetch(:matches, []) + [:host]
    end

    def fulfills_request?(vcr_request)
      VCR::API::URIMatcher.new(self, vcr_request).matches?
    end

    def request_expired?(vcr_request)
      VCR::API::ExpirationMatcher.new(self, vcr_request).expired?
    end

    def path_for_request(vcr_request)
      VCR::API::CassetteName.new(self, vcr_request).name
    end
  end
end
