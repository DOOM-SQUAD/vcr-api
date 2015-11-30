module VCR
  class API
    class CassetteName
      attr_reader :vcr_request, :service, :request_uri

      def initialize(service, vcr_request)
        @vcr_request = vcr_request
        @request_uri = URI.parse(vcr_request.uri)
        @service = service
      end

      def name
        File.join(prefix, host, path, method, [query, body].join('_'))
      end

      def prefix
        "api/#{service.service_name}"
      end

      def host
        port = request_uri.port unless request_uri.port == 80
        [request_uri.host, port].compact.join("_")
      end

      def path
        request_uri.path
      end

      def method
        vcr_request.method.to_s.upcase
      end

      def query
        if request_uri.query
          request_uri.query.gsub(/[^a-z0-9_]+/i, '_')
        else
          'no_query'
        end
      end

      def body
        if vcr_request.body.size > 0
          Digest::SHA1.hexdigest(vcr_request.body).slice(0..9)
        else
          'empty_body'
        end
      end
    end
  end
end
