require 'spec_helper'

describe VCR::API do
  it 'has a version number' do
    expect(VCR::API::VERSION).not_to be nil
  end

  describe '#can_fullfill_request?' do
    subject(:api) { VCR::API.new(:test, 'http://httbin.org/') }

    context 'when request is to a knwon api' do
      let(:request) { VCR::Request.new(:get, 'http://httbin.org/get') }

      it 'is true' do
        expect(api.fulfills_request?(request)).to be true
      end
    end


    context 'when request is not to a known api' do
      let(:request) { VCR::Request.new(:get, 'http://httpbin.com/get') }

      it 'is false' do
        expect(api.fulfills_request?(request)).to be false
      end
    end
  end
end
