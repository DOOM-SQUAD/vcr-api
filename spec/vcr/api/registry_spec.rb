require 'spec_helper'

RSpec.describe VCR::API::Registry do
  let(:api) { VCR::API.new(:test, 'http://httbin.org') }

  describe '#add' do
    it 'adds an api to the known api' do
      expect { subject.add(api) }
        .to change { subject.registry.include?(api) }
        .from(false)
        .to(true)
    end
  end

  describe '#api_for' do
    before do
      subject.add(api)
    end

    context 'when a service is found' do
      let(:request) { VCR::Request.new(:get, 'http://httbin.org/get') }

      it 'returns the service name' do
        expect(subject.api_for(request)).to eq(api)
      end
    end

    context 'when no service is found' do
      let(:request) { VCR::Request.new(:get, 'http://foaas.org/fuckoff') }

      it 'returns nil' do
        expect(subject.api_for(request)).to be nil
      end
    end
  end


  describe '#known' do
    before do
      subject.add(api)
    end

    it 'lists the service names of all known apis' do
      expect(subject.known).to eq [:test]
    end
  end


  describe '#known?' do
    before do
      subject.add(api)
    end

    it 'queries on service name' do
      expect(subject.known?(:test)).to be true
    end
  end
end
