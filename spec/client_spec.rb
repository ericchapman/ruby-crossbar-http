require 'spec_helper'

describe Crossbar::HTTP::Client do
  let(:url)           { 'http://www.example.com/bridge'}
  let(:client)        { Crossbar::HTTP::Client.new(url, verbose: false) }
  let(:client_secure) { Crossbar::HTTP::Client.new(url, key: 'key', secret: 'secret', verbose: false) }

  describe '#call' do
  end

  describe '#_compute_signature' do
    it 'it correctly calculates the signature' do
      signature, nonce, timestamp = client_secure._compute_signature('test body', nonce: 22, timestamp: '2017-01-22T01:53:41.778Z')
      expect(signature).to eq('srXq9gLeDIDapOTbReTay-LbcdBtnIdMJzXU82KMoV4=')
    end
  end
end
