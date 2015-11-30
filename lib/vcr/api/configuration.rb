module VCR
  class API
    module Configuration
      attr_accessor :record_feature_interactions

      SELENIUM_IGNORER = proc { |req| req.uri =~ /http:\/\/127.0.0.1:7055\/hub/ && Capybara.current_driver == :selenium }

      def add_api(service_name, address, **options)
        api_registry.add(VCR::API.new(service_name, address, **options))
      end

      def api_registry
        @api_registry ||= VCR::API::Registry.new
      end

      def always_allow_api_access=(flag)
        api_registry.always_allow = flag
      end

      def record_feature_interactions=(flag)
        if flag == false
          ignored_browser_controllers.each do |ignorer|
            VCR.request_ignorer.ignore_request(&ignorer)
          end
        else
          VCR.request_ignorer.hooks[:ignore_request].delete_if do |hook|
            ignored_browser_controllers.include? hook.hook
          end
        end
      end

      def ignored_browser_controllers
        [SELENIUM_IGNORER]
      end
    end

    VCR::Configuration.send(:include, VCR::API::Configuration)
    VCR.configuration.record_feature_interactions = false
  end
end
