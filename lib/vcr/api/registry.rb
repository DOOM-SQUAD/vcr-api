module VCR
  class API
    class Registry
      attr_reader :registry, :enabled

      def initialize
        @registry = Set.new
        @enabled = {}
        @always_allow = false
      end

      def always_allow=(flag)
        @always_allow = flag
      end

      def always_allow?
        @always_allow
      end

      def add(api)
        registry << api
      end

      def api_for(vcr_request)
        registry.detect { |api| api.fulfills_request?(vcr_request) }
      end

      def disable_all!
        registry.each do |api|
          disable!(api.service_name)
        end
      end

      def enable_all!
        registry.each do |api|
          enable!(api.service_name)
        end
      end

      def disable!(service_name)
        enabled[service_name] = false
      end

      def enable!(service_name)
        enabled[service_name] = true
      end

      def enabled?(service_name)
        return true if always_allow?
        !!enabled[service_name]
      end

      def disabled?(service_name)
        not enabled?(service_name)
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
