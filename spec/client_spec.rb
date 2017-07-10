require 'spec_helper'

describe Crossbar::HTTP::Client do
  let(:url)           { 'http://www.example.com/bridge'}
  let(:client)        { Crossbar::HTTP::Client.new(url, verbose: false) }
  let(:client_secure) { Crossbar::HTTP::Client.new(url, key: 'key', secret: 'secret', verbose: false) }
  let(:args)          { [1, 2, 3] }
  let(:kwargs)        { { param1: true, param2: false } }

  context 'json_custom' do
    it 'changes a few different types of objects' do

      pre_serialize = lambda { |value|
        if value.is_a? Date
          return value.strftime('%Y/%m/%d')
        elsif value.is_a? Integer
          return value.to_s
        end
      }

      client = Crossbar::HTTP::Client.new(url, verbose: false, pre_serialize: pre_serialize)
      stub_api_call client
      kwargs = {
          test_array: [1, 2, 3],
          test_dict: {
              test_date: Date.strptime('2017-01-22T01:53:41.778Z', '%Y-%m-%dT%H:%M:%S.%LZ')
          },
          test_int: 2
      }
      response = client.call('com.example.procedure', **kwargs)

      expected = {
          test_array: ['1', '2', '3'],
          test_dict: {
              test_date: '2017/01/22'
          },
          test_int: '2'
      }
      expect(response[:body][:kwargs]).to eq(expected)
    end
  end

  context 'public methods' do
    before(:each) do
      stub_timestamp
      stub_nonce
      stub_api_call client
      stub_api_call client_secure
    end

    describe '#publish' do
      it 'creates a normal publish request' do
        result = client.publish('com.example.topic', *args, **kwargs)

        uri = result[:uri]
        expect(uri.to_s).to eq('http://www.example.com/bridge')

        body = result[:body]
        expect(body).to eq({ topic: 'com.example.topic', args: args, kwargs: kwargs })
      end

      it 'creates a secure publish request' do
        result = client_secure.publish('com.example.topic', *args, **kwargs)

        uri = result[:uri]
        expect(uri.to_s).to eq('http://www.example.com/bridge?timestamp=2017-01-22T01%3A53%3A41.778Z&seq=1&nonce=22&signature=7wIQ_VgAyiTBBCsaQtMj391bFwYlHoWkZgUjXRU_1tg%3D&key=key')

        body = result[:body]
        expect(body).to eq({ topic: 'com.example.topic', args: args, kwargs: kwargs })
      end
    end

    describe '#call' do
      it 'creates a normal call request' do
        result = client.call('com.example.procedure', *args, **kwargs)

        uri = result[:uri]
        expect(uri.to_s).to eq('http://www.example.com/bridge')

        body = result[:body]
        expect(body).to eq({ procedure: 'com.example.procedure', args: args, kwargs: kwargs })
      end

      it 'creates a secure publish request' do
        result = client_secure.call('com.example.procedure', *args, **kwargs)

        uri = result[:uri]
        expect(uri.to_s).to eq('http://www.example.com/bridge?timestamp=2017-01-22T01%3A53%3A41.778Z&seq=1&nonce=22&signature=UQxwY7SP9F5jxb9BhHt20kgaic0TFsY5zb5gNm2hXLE%3D&key=key')

        body = result[:body]
        expect(body).to eq({ procedure: 'com.example.procedure', args: args, kwargs: kwargs })
      end
    end

  end

  context 'private_methods' do
    describe '#_compute_signature' do
      let(:expected) { 'srXq9gLeDIDapOTbReTay-LbcdBtnIdMJzXU82KMoV4=' }

      it 'correctly calculates the signature' do
        stub_timestamp
        stub_nonce
        signature, nonce, timestamp = client_secure._compute_signature('test body')
        expect(signature).to eq(expected)
      end

      it 'generates a different signature when nonce and timestamp are not stubbed' do
        signature, nonce, timestamp = client_secure._compute_signature('test body')
        expect(signature).not_to eq(expected)
      end
    end

    describe '#_api_call' do
      it 'makes a http call' do
        uri = URI('http://httpbin.org/post')
        body = '{"test": true}'
        response = client._api_call(uri, body)
        expect(response[:data]).to eq(body)
      end

      it 'makes a https call' do
        uri = URI('https://httpbin.org/post')
        body = '{"test": true}'
        response = client._api_call(uri, body)
        expect(response[:data]).to eq(body)
      end

      it 'returns an error' do
        uri = URI('https://httpbin.org/status/404')
        expect {
          client._api_call(uri)
        }.to raise_error(Exception)
      end
    end
  end

end
