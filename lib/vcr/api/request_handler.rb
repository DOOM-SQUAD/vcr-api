require 'vcr/request_handler'

module VCR
  class API
    class APIDisabled < StandardError; end

    module RequestHandler
      def request_type_with_api(consume_stub = false)
        if api_request?
          :api_stubbed
        elsif browser_request?
          :browser
        else
          request_type_without_api(consume_stub)
        end
      end

      def api_request?
        @service = VCR.configuration.api_registry.api_for(vcr_request)

        if @service.nil?
          false
        elsif VCR.configuration.api_registry.disabled?(@service.service_name)
          fail APIDisabled, "The API '#{@service.service_name}' is not enabled"
        else
          true
        end
      end

      def browser_request?
        VCR.configuration.ignored_browser_controllers
          .map { |ignorer| ignorer.call(vcr_request) }.any?
      end

      def on_api_stubbed_request
        VCR.use_cassette(@service.path_for_request(vcr_request)) do
          send "on_#{request_type_without_api}_request"
        end
      end

      def on_browser_request
        if VCR.configuration.record_feature_interactions
          send "on_#{request_type_without_api}_request"
        else
          on_ignored_request
        end
      end
    end
  end

  class RequestHandler
    include VCR::API::RequestHandler

    # We can't just prepend, because we need to call the 'without' method in
    # two different places
    alias_method :request_type_without_api, :request_type
    alias_method :request_type, :request_type_with_api
  end
end
