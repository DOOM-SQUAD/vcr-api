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

    context 'can set the specificity of the match' do

      context 'when protocol is set' do
        subject(:api) { VCR::API.new(:test, 'https://httbin.org', matches: [:protocol]) }
        let(:request) { VCR::Request.new(:get, 'http://httbin.org/get') }

        it 'only matches when protocol matches' do
          expect(api.fulfills_request?(request)).to be false
        end
      end

      context 'when port is set' do
        subject(:api) { VCR::API.new(:test, 'http://httbin.org:80', matches: [:port]) }
        let(:request) { VCR::Request.new(:get, 'http://httbin.org:3000/get') }

        it 'only matches when port matches' do
          expect(api.fulfills_request?(request)).to be false
        end
      end

      context 'when url_prefix is set' do
        subject(:api) { VCR::API.new(:test, 'http://httbin.org/api/v1', matches: [:url_prefix]) }
        let(:request) { VCR::Request.new(:get, 'http://httbin.org/get') }

        context 'when the url contains the prefix' do
          let(:request) { VCR::Request.new(:get, 'http://httbin.org/api/v1/get/thing') }

          it 'matches' do
            expect(api.fulfills_request?(request)).to be true
          end
        end

        context 'when the url does not contain the prefix' do
          let(:request) { VCR::Request.new(:get, 'http://httbin.org/api/v2/get/thing') }

          it 'does not match' do
            expect(api.fulfills_request?(request)).to be false
          end
        end
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
