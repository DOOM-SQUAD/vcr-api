require 'spec_helper'

describe VCR::API::ExpirationMatcher do
  context 'allows settings an expires option' do
    let(:request) { VCR::Request.new(:get, 'http://localhost:9293') }

    context 'when expires is true' do
      context 'when the api can be reached', :server do
        let(:api) { VCR::API.new(:test, 'http://localhost:9293', expires: true) }

        it 'will make a request' do
          expect(api.request_expired?(request)).to be true
        end
      end

      context 'when the api cannot be reached' do
        let(:api) { VCR::API.new(:test, 'http://localhost:9293', expires: true) }

        # the lack of :server metadata here means it will not be running
        it 'will not make a request' do
          expect(api.request_expired?(request)).to be false
        end
      end
    end

    context 'when expires is false' do
      let(:api) { VCR::API.new(:test, 'http://localhost:9293') }

      it 'will not make a request' do
        expect(api.request_expired?(request)).to be false
      end
    end

    context 'when expires is an integer' do
      let(:api) { VCR::API.new(:test, 'http://localhost:9293', expires: 1) }

      before do
        allow(VCR.configuration).to receive(:cassette_library_dir).and_return('spec/vcr/fixtures')
      end

      context 'when the api can be reached', :server do
        it 'the request is older than interval' do
          expect(api.request_expired?(request)).to be true
        end
      end
    end

    context 'when expires is callable' do
      context 'when expires returns true' do
        let(:api) { VCR::API.new(:test, 'http://localhost:9293', expires: ->(req) { true }) }

        context 'and the api can be reached', :server do
          it 'will try to make a request if the service can be reached' do
            expect(api.request_expired?(request)).to be true
          end
        end

        context 'and the api cannot be reached' do
          it 'will not try to make a request if the service cannot be reached' do
            expect(api.request_expired?(request)).to be false
          end
        end
      end

      context 'when expires returns false' do
        let(:api) { VCR::API.new(:test, 'http://localhost:9293', expires: ->(req) { false }) }

        it 'will not make a request' do
          expect(api.request_expired?(request)).to be false
        end
      end
    end

    context 'when you say "expired" instead of "expires"', :server do
      let(:api) { VCR::API.new(:test, 'http://localhost:9293', expired: ->(req) { true }) }

      it 'aliases expires is to expired' do
        expect(api.request_expired?(request)).to be true
      end
    end
  end
end
