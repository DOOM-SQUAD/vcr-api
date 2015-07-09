require 'spec_helper'

RSpec.describe VCR::API::Matcher do
  let(:request1) { VCR::Request.new(:get, 'http://localhost:3000/get?blah=blue&bluh=blah', nil, 'Accept' => 'application/json') }
  let(:request2) { VCR::Request.new(:get, 'http://localhost:3000/get?blah=blue&bluh=blah', nil, 'Accept' => 'application/json') }

  describe '#call' do
    context 'when requests are exactly the same' do
      it 'should match' do
        expect(VCR::API::Matcher.new.call(request1, request2)).to be true
      end
    end

    context 'when requests have different parameter order' do
      let(:request2) { VCR::Request.new(:get, '/get?bluh=blah&blah=blue', nil, 'Accept' => 'application/json') }

      it 'should match' do
        expect(VCR::API::Matcher.new.call(request1, request2)).to be true
      end
    end
  end
end
