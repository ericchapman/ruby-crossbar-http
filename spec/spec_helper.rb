require 'simplecov'
SimpleCov.start

if ENV['CODECOV_TOKEN']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'crossbar-http'

def stub_timestamp
  @timestamp = '2017-01-22T01:53:41.778Z'
  allow(described_class).to receive(:_get_timestamp) {
    @timestamp
  }
end

def stub_nonce
  @nonce = 22
  allow(described_class).to receive(:_get_nonce) { @nonce }
end

def stub_api_call(client)
  allow(client).to receive(:_api_call) { |uri, body|
    { uri: uri, body: JSON.parse(body, symbolize_names: true) }
  }
end
