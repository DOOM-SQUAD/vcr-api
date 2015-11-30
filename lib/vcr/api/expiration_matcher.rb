require 'net/http'

module VCR
  class API
    class ExpirationMatcher
      class NeverRecorded < StandardError; end

      attr_reader :service, :request

      def initialize(service, request)
        @service = service
        @request = request
      end

      def expired?
        case service.expires
        when TrueClass then reachable?
        when FalseClass then false
        when Integer then reachable? && outdated?
        when Proc then service.expires.call(request) && reachable?
        end
      end

      def reachable?
        disabling_webmock do
          Net::HTTP.start(service.endpoint.host, service.endpoint.port)
        end
        true
      rescue
        false
      end

      def outdated?
        (Time.now.to_i - service.expires) > last_recorded_timestamp
      rescue NeverRecorded
        true
      end

      private

      def last_recorded_timestamp
        if File.exist?(cassette_file)
          File.mtime(cassette_file)
        else
          raise ExpirationMatcher::NeverRecorded
        end
      end

      def disabling_webmock
        unless Object.const_defined?(:WebMock)
          yield and return
        end

        begin
          WebMock.disable!
          yield
        ensure
          WebMock.enable!
        end
      end

      private

      def cassette_file
        File.join(VCR.configuration.cassette_library_dir, service.path_for_request(request))
      end
    end
  end
end
