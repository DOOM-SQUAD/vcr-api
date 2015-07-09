require 'spec_helper'

RSpec.describe VCR::API::Configuration  do
  describe '#add_api' do
    before do
      VCR.configure do |c|
        c.add_api :test_api, 'localhost:3002'
      end
    end

    it 'can add the api to its record list' do
      expect(VCR.configuration.api_registry.known?(:test_api)).to be true
    end

    it 'can add the api to its record list' do
      expect(VCR.configuration.api_registry.known).to include(:test_api)
    end

    it 'creates rspec metadata which hooks into that' do
      pending 'will implement someday'
    end
  end

  it 'has added some methods to the VCR configuration method' do
    expect { |b| VCR.configure(&b) }.to yield_with_args(->(c){ c.respond_to?(:add_api) })
  end
end
