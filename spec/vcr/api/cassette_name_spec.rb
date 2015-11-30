require 'spec_helper'

RSpec.describe VCR::API::CassetteName do
  let(:request) { VCR::Request.new(:get, 'http://localhost:3000/get?blah=blue&bluh=blah',
                                    nil, 'Accept' => 'application/json') }

  let(:test_api) { VCR::API.new(:test_api, 'http://localhost:3000') }

  subject { described_class.new(test_api, request) }

  describe '#name' do
    it 'includes standard path' do
      expect(subject.name).to start_with("api/test_api/localhost_3000")
    end

    context 'when there is a path' do
      it 'includes uri path component' do
        expect(subject.name).to include("/get")
      end
    end

    context 'when there is a method' do
      it 'includes a method component' do
        expect(subject.name).to include('GET')
      end
    end

    context 'when there is a query string' do
      it 'includes a santized version of the query string' do
        expect(subject.name).to include('blah_blue_bluh_blah')
      end
    end

    context 'when there is no query string' do
      let(:request) { VCR::Request.new(:get, 'http://localhost:3000/get',
                                    nil, 'Accept' => 'application/json') }

      it 'includes "no_query"' do
        expect(subject.name).to include("no_query")
      end
    end

    context 'when there is a request body' do
      let(:request) { VCR::Request.new(:get, 'http://localhost:3000/get',
                                    'hello world', 'Accept' => 'application/json') }

      it 'includes a hash of the request body' do
        expect(subject.name).to end_with('2aae6c35c9')
      end
    end

    context 'when there is no body' do
      it 'includes "empty_body"' do
        expect(subject.name).to end_with('empty_body')
      end
    end
  end
end
