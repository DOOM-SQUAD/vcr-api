require 'spec_helper'

RSpec.describe VCR::API::Configuration  do
  describe '#add_api' do
    before do
      VCR.configure do |c|
        c.add_api :test_api, 'localhost:3002'
        c.add_api :test2_api, 'localhost:3003'
        c.always_allow_api_access = false
      end
    end

    it 'can add the api to its record list' do
      expect(VCR.configuration.api_registry.known?(:test_api)).to be true
    end

    it 'can add the api to its record list' do
      expect(VCR.configuration.api_registry.known).to include(:test_api)
    end

    context 'creates rspec metadata which hooks into that' do
      it 'enables the api for tagged examples', apis: [:test_api] do
        expect(VCR.configuration.api_registry.enabled?(:test_api)).to be true
      end

      it 'disables apis not specifically listed', apis: [:test_api] do
        expect(VCR.configuration.api_registry.enabled?(:test2_api)).to be false
      end

      it 'disables the api for untagged examples' do
        expect(VCR.configuration.api_registry.enabled?(:test_api)).to be false
      end

      it 'enables all apis without a specific list', :apis do
        aggregate_failures do
          expect(VCR.configuration.api_registry.enabled?(:test_api)).to be true
          expect(VCR.configuration.api_registry.enabled?(:test2_api)).to be true
        end
      end
    end

    describe '#record_feature_interactions' do
      let(:active_hook_procs) { VCR.request_ignorer.hooks[:ignore_request].map(&:hook) }

      context 'when set to false' do
        it 'adds browser driver ignorers to the request ignorer' do
          VCR.configuration.record_feature_interactions = false
          expect(active_hook_procs.include?(VCR::API::Configuration::SELENIUM_IGNORER)).to be true
        end
      end

      context 'when set to true' do
        it 'adds browser driver ignorers to the request ignorer' do
          VCR.configuration.record_feature_interactions = true
          expect(active_hook_procs.include?(VCR::API::Configuration::SELENIUM_IGNORER)).to be false
        end
      end
    end
  end

  it 'has added some methods to the VCR configuration method' do
    expect { |b| VCR.configure(&b) }.to yield_with_args(->(c){ c.respond_to?(:add_api) })
  end
end
