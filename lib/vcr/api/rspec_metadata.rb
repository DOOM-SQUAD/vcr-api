module VCR
  class API
    module RSpec
      class APIEnabler
        def self.enable_all
          VCR.configuration.api_registry.enable_all!
          yield
        ensure
          VCR.configuration.api_registry.disable_all!
        end

        def self.enable_some(options)
          VCR.configuration.api_registry.disable_all!

          options.each do |api|
            VCR.configuration.api_registry.enable!(api)
          end

          yield
        ensure
          VCR.configuration.api_registry.disable_all!
        end
      end

      module Metadata
        extend self

        def configure!
          when_apis_enabled = { :apis => lambda { |v| !!v } }
          ::RSpec.configure do |config|
            config.around(:each, when_apis_enabled) do |ex|
              example = ex.respond_to?(:metadata) ? ex : ex.example

              options = example.metadata[:apis]

              if options.is_a?(Array)
                APIEnabler.enable_some(options) do
                  ex.run
                end
              else
                APIEnabler.enable_all do
                  ex.run
                end
              end
            end
          end
        end

        configure!
      end
    end
  end
end
