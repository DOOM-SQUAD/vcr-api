require 'spec_helper'
require 'open-uri'

RSpec.describe VCR::API::RequestHandler do
  let(:request) { VCR::Request.new(:get, 'http://localhost:3000/get?blah=blue&bluh=blah',
                                    nil, 'Accept' => 'application/json') }

  subject(:request_handler) { VCR::RequestHandler.new }

  before do
    allow(request_handler).to receive(:vcr_request).and_return(request)
  end

  before do
    VCR.configure do |c|
      c.add_api :test_api, 'http://ww2.httpbin.org'
      c.add_api :localtest, 'http://localhost:3000'
      c.always_allow_api_access = true
      c.ignore_localhost = false
    end
  end

  describe '#request_type' do
    it 'should return :api_stubbed for api requests' do
      expect(subject.request_type).to eq :api_stubbed
    end

    context 'when record feature interactions is false', :server do
      before do
        VCR.configure do |c|
          c.record_feature_interactions = false
        end
      end

      after do
        FileUtils.rm_rf(File.expand_path("#{__FILE__}/../../../../tmp"))
      end

      context 'with selenium', :js, type: :feature do
        before do
          Capybara.current_driver = :selenium
          Capybara.javascript_driver = :selenium
        end

        it 'should detect and allow requests to the browser' do
          Faraday.get('http://ww2.httpbin.org/ip')
            visit 'http://localhost:9293'
            click_on "Click here"

          expect(File).to exist('tmp/api/test_api/ww2_httpbin_org/ip/GET/no_query_empty_body.yml')

          expect('tmp/api/test_api/ww2_httpbin_org/ip/GET/no_query_empty_body.yml')
            .to not_include_requests_to_url(/http:\/\/127.0.0.1:7055\/hub/)
            .and not_include_requests_to_url('http://localhost:9293')
        end
      end
    end

    context 'when record feature interaction is true', :js, :server, type: :feature do
      before do
        Capybara.current_driver = :selenium
        Capybara.javascript_driver = :selenium
      end

      after do
        FileUtils.rm_rf(File.expand_path("#{__FILE__}/../../../../tmp"))
      end

      it 'has the default behavior' do
        Faraday.get('http://ww2.httpbin.org/ip')
        visit 'http://localhost:9293'
        click_on "Click here"

        aggregate_failures do
          expect(File).to exist('tmp/api/test_api/ww2_httpbin_org/ip/GET/no_query_empty_body.yml')

          expect('tmp/api/test_api/ww2_httpbin_org/ip/GET/no_query_empty_body.yml')
            .to not_include_requests_to_url(/http:\/\/127.0.0.1:7055\/hub/)
            .and not_include_requests_to_url('http://locahost:9293')
        end
      end
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
        VCR.configuration.always_allow_api_access = false
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
