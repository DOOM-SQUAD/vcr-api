require 'vcr/request_handler'

module VCR
  class API
    class APIDisabled < StandardError; end

    module RequestHandler
      def request_type_with_api(consume_stub = false)
        if api_request?
          :api_stubbed
        else
          request_type_without_api
        end
      end

      def api_request?
        @api = VCR.configuration.api_registry.api_for(vcr_request)
        return false if @api.nil?
        fail APIDisabled unless VCR.configuration.api_registry.enabled?(@api.service_name)
        true
      end

      def on_api_stubbed_request
        VCR.use_cassette(cassette_path) do
          send "on_#{request_type_without_api}_request"
        end
      end

      def cassette_path
        VCR::API::CassetteName.new(@api.service_name, vcr_request).name
      end
    end
  end

  class RequestHandler
    include VCR::API::RequestHandler

    alias_method :request_type_without_api, :request_type
    alias_method :request_type, :request_type_with_api
  end
end
