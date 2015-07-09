module VCR
  class API
    class Registry
      attr_reader :registry, :enabled

      def initialize
        @registry = Set.new
        @enabled = {}
      end

      def add(api)
        registry << api
        enabled[api.service_name] = true
      end

      def api_for(vcr_request)
        registry.detect { |api| api.fulfills_request?(vcr_request) }
      end

      def disable!(service_name)
        enabled[service_name] = false
      end

      def enable!(service_name)
        enabled[service_name] = true
      end

      def enabled?(service_name)
        enabled[service_name]
      end

      def known?(service_name)
        known.include?(service_name)
      end

      def known
        registry.map { |api| api.service_name }
      end
    end
  end
end
