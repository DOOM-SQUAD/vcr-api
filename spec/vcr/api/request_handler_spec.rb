require 'spec_helper'

RSpec.describe VCR::API::RequestHandler do
  let(:request) { VCR::Request.new(:get, 'http://localhost:3000/get?blah=blue&bluh=blah',
                                    nil, 'Accept' => 'application/json') }

  subject(:request_handler) { VCR::RequestHandler.new }

  before do
    allow(request_handler).to receive(:vcr_request).and_return(request)
  end

  before do
    VCR.configure do |c|
      c.add_api :test, 'http://localhost:3000'
    end
  end


  describe '#request_type' do
    it 'should return :api_stubbed for api requests' do
      expect(subject.request_type).to eq :api_stubbed
    end
  end

  describe '#api_request?' do
    context 'when the api is known and enabled' do
      it 'returns true' do
        expect(subject.api_request?).to be true
      end
    end

    context 'when the api is known but disabled' do
      before do
        VCR.configuration.api_registry.disable!(:test)
      end

      it 'raises an error' do
        expect { subject.api_request? }.to raise_error(VCR::API::APIDisabled)
      end
    end

    context 'when the api is unknown' do
      let(:request) { VCR::Request.new(:get, 'http://httbin.org/get?blah=blue&bluh=blah',
                                        nil, 'Accept' => 'application/json') }

      it 'returns false' do
        expect(subject.api_request?).to be false
      end
    end
  end
end
