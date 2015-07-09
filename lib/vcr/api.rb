require "vcr/api/version"

require_relative 'api/configuration'
require_relative 'api/request_handler'
require_relative 'api/matcher'
require_relative 'api/registry'
require_relative 'api/cassette_name'

module VCR
  class API
    class URIMatcher
      attr_reader :endpoint, :request

      def initialize(endpoint, request)
        @endpoint = endpoint
        @request = request
      end

      def host
        endpoint.host == request.host
      end

      def port
        endpoint.port == request.port
      end

      def protocol
        endpoint.scheme == request.scheme
      end

      def url_prefix
        request.path.start_with?(endpoint.path)
      end
    end

    attr_reader :endpoint, :service_name

    def initialize(service_name, address, **options)
      @endpoint = URI.parse(address)
      @service_name = service_name
      @expires = options.fetch(:expires, false)
      @match_on = options.fetch(:matches, []) + [:host]
    end

    def fulfills_request?(vcr_request)
      request = URI.parse(vcr_request.uri)
      matcher = VCR::API::URIMatcher.new(endpoint, request)

      @match_on.all? { |dimension| matcher.send(dimension) }
    end
  end
end
