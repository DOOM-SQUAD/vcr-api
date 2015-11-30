require 'spec_helper'

require 'faraday'

RSpec.describe 'it works as expected' do
  before do
    VCR.configure do |vcr|
      vcr.add_api :test_api, 'http://ww2.httpbin.org'
      vcr.always_allow_api_access = true
    end
  end

  let(:connection) { Faraday.new(url: 'http://ww2.httpbin.org') }

  context 'recording interactions' do
    after do
      FileUtils.rm_rf(File.expand_path("#{__dir__}/../../tmp"))
    end

    it 'records the interaction', :vcr, apis: [:test_api] do
      connection.get('/get')
      expect(File).to exist('tmp/api/test_api/ww2_httpbin_org/get/GET/no_query_empty_body.yml')
    end

    it 'records the interaction in separate cassettes', :vcr, apis: [:test_api] do
      connection.get('/get')
      Faraday.get('http://jsonplaceholder.typicode.com/posts/1')

      VCR.eject_cassette

      expect(File).to exist('tmp/api/test_api/ww2_httpbin_org/get/GET/no_query_empty_body.yml')
      expect(File).to exist('tmp/it_works_as_expected/recording_interactions/records_the_interaction_in_separate_cassettes.yml')
    end

    it 'records all api interactions in separate cassettes', :vcr, apis: [:test_api]  do
      connection.get('/get')
      Faraday.get('http://jsonplaceholder.typicode.com/posts/1')
      connection.get('/ip')
      Faraday.get('http://jsonplaceholder.typicode.com/comments/1')

      VCR.eject_cassette

      expect(File).to exist('tmp/api/test_api/ww2_httpbin_org/get/GET/no_query_empty_body.yml')
      expect(File).to exist('tmp/api/test_api/ww2_httpbin_org/ip/GET/no_query_empty_body.yml')
      expect(File).to exist('tmp/it_works_as_expected/recording_interactions/records_all_api_interactions_in_separate_cassettes.yml')
    end
  end

  context 'playing back interactions' do
    before do
      # there's no way to be specific about the cassets in multiple let bocks,
      # so this our options.
      VCR.use_cassette('test_cassette') do
        @get_results = connection.get('/get').body
        @post_results = Faraday.get('http://jsonplaceholder.typicode.com/posts/1').body
        @ip_results = connection.get('/ip').body
        @comment_results = Faraday.get('http://jsonplaceholder.typicode.com/comments/1').body
      end
    end

    after do
      FileUtils.rm('tmp/test_cassette.yml')
      FileUtils.rm_rf(File.expand_path("#{__dir__}/../../tmp"))
    end

    it 'does not connect to the network for the same series of requests' do
      expect(Net::HTTP).to_not receive(:new)

      VCR.use_cassette('test_cassette') do
        expect(connection.get('/get').body).to eq @get_results
        expect(Faraday.get('http://jsonplaceholder.typicode.com/posts/1').body).to eq @post_results
        expect(connection.get('/ip').body).to eq @ip_results
        expect(Faraday.get('http://jsonplaceholder.typicode.com/comments/1').body).to eq @comment_results
      end
    end

    it 'raises an error if you try to use an api you are not enabled for' do
      VCR.configuration.api_registry.always_allow = false
      expect { connection.get('/get') }.to raise_error VCR::API::APIDisabled, "The API 'test_api' is not enabled"
    end
  end
end
