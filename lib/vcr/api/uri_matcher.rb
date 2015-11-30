module VCR
  class API
    class URIMatcher
      attr_reader :service, :request

      def initialize(service, request)
        @service = service
        @request = request
      end

      def matches?
        service.match_on.all? { |dimension| send(dimension) }
      end

      def host
        service.host == request_uri.host
      end

      def port
        service.port == request_uri.port
      end

      def protocol
        service.scheme == request_uri.scheme
      end

      def url_prefix
        request_uri.path.start_with?(service.path)
      end

      def request_uri
        @request_uri ||= URI.parse(request.uri)
      end
    end
  end
end
