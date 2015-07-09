module VCR
  class API
    module Configuration
      def add_api(service_name, address, **options)
        api_registry.add(VCR::API.new(service_name, address, **options))
      end

      def api_registry
        @api_registry ||= VCR::API::Registry.new
      end
    end

    VCR::Configuration.send(:include, VCR::API::Configuration)
  end
end
