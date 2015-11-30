require 'spec_helper'

describe VCR::API::URIMatcher do
  let(:api) { VCR::API.new(:test, 'https://httbin.org') }
  subject(:matcher) { VCR::API::URIMatcher.new(api, request) }

  context 'can set the specificity of the match' do
    context 'when protocol is set' do
      let(:api) { VCR::API.new(:test, 'https://httbin.org', matches: [:protocol]) }
      let(:request) { VCR::Request.new(:get, 'http://httbin.org/get') }

      it 'only matches when protocol matches' do
        expect(matcher.matches?).to be false
      end
    end

    context 'when port is set' do
      let(:api) { VCR::API.new(:test, 'http://httbin.org:80', matches: [:port]) }
      let(:request) { VCR::Request.new(:get, 'http://httbin.org:3000/get') }

      it 'only matches when port matches' do
        expect(matcher.matches?).to be false
      end
    end

    context 'when url_prefix is set' do
      let(:api) { VCR::API.new(:test, 'http://httbin.org/api/v1', matches: [:url_prefix]) }
      let(:request) { VCR::Request.new(:get, 'http://httbin.org/get') }

      context 'when the url contains the prefix' do
        let(:request) { VCR::Request.new(:get, 'http://httbin.org/api/v1/get/thing') }

        it 'matches' do
          expect(matcher.matches?).to be true
        end
      end

      context 'when the url does not contain the prefix' do
        let(:request) { VCR::Request.new(:get, 'http://httbin.org/api/v2/get/thing') }

        it 'does not match' do
          expect(matcher.matches?).to be false
        end
      end
    end
  end
end
