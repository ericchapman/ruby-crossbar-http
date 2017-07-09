=begin

Copyright (c) 2017 Eric Chapman

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=end

require 'openssl'
require 'base64'
require 'net/http'
require 'json'

module Crossbar
  module HTTP
    class Client
      attr_accessor :url, :key, :secret, :verbose, :sequence

      # Initializes the client
      # @param url [String] - The url of the router's HTTP bridge
      # @param key [String] - The key (optional)
      # @param secret [String] - The secret (optional)
      # @param verbose [Bool] - 'True' if you want debug messages printed
      def initialize(url, key: nil, secret: nil, verbose: false)

        raise 'The url can not be nil' unless url != nil

        self.url = url
        self.key = key
        self.secret = secret
        self.verbose = verbose
        self.sequence = 1
      end

      # Publishes to the topic
      # @param topic [String] - The name of the topic
      # @param *args [] - The arguments and key word arguments
      # @return [Integer] - Returns the id of the publish
      def publish(topic, *args, **kwargs)
        raise 'The topic can not be nil' unless url != nil

        params = {
            topic: topic,
            args: args,
            kwargs: kwargs
        }

        self._make_api_call(params)
      end

      # Calls the procedure
      # @param procedure [String] - The name of the topic
      # @param *args [] - The arguments and key word arguments
      # @return [Integer] - Returns the id of the publish
      def call(procedure, *args, **kwargs)
        raise 'The topic can not be nil' unless url != nil

        params = {
            procedure: procedure,
            args: args,
            kwargs: kwargs
        }

        self._make_api_call(params)
      end

      # Computes the signature.
      # Described at: http://crossbar.io/docs/HTTP-Bridge-Services-Caller/
      # Reference code is at: https://github.com/crossbario/crossbar/blob/master/crossbar/adapter/rest/common.py
      # @param body [Hash]
      # @return (signature, nonce, timestamp)
      def _compute_signature(body)
        timestamp = self.class._get_timestamp
        nonce = self.class._get_nonce

        # Compute signature: HMAC[SHA256]_{secret} (key | timestamp | seq | nonce | body) => signature
        hm = OpenSSL::HMAC.new(self.secret, OpenSSL::Digest::SHA256.new)
        hm << self.key
        hm << timestamp
        hm << self.sequence.to_s
        hm << nonce.to_s
        hm << body
        signature = Base64.urlsafe_encode64(hm.digest)

        return signature, nonce, timestamp
      end

      def self._get_timestamp
        Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
      end

      def self._get_nonce
        rand(0..2**53)
      end

      # Performs the API call
      # @param json_params [Hash,nil] The parameters that will make up the body of the request
      # @return [Hash] The response from the server
      def _make_api_call(json_params=nil)

        puts "Crossbar::HTTP - Request: POST #{url}" if self.verbose

        encoded_params = (json_params != nil) ? JSON.generate(json_params) : nil

        puts "Crossbar::HTTP - Params: #{encoded_params}" if encoded_params != nil and self.verbose

        uri = URI(self.url)

        if self.key != nil and self.secret != nil and encoded_params != nil
          signature, nonce, timestamp = self._compute_signature(encoded_params)
          params = {
              timestamp: timestamp,
              seq: self.sequence.to_s,
              nonce: nonce,
              signature: signature,
              key: self.key
          }
          uri.query = URI.encode_www_form(params)

          puts "Crossbar::HTTP - Signature Params: #{params}" if self.verbose
        end

        # TODO: Not sure what this is supposed to be but this works
        self.sequence += 1

        self._api_call uri, encoded_params
      end

      # This method makes tha API call.  It is a class method so it can be more easily stubbed
      # for testing
      # @param uri [URI] The uri of the request
      # @param body [String] The body of the request
      # @return [Hash] The response from the server
      def _api_call(uri, body=nil)
        # Create the request
        res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          req = Net::HTTP::Post.new(uri)
          req['Content-Type'] = 'application/json'
          req.body = body

          http.request(req)
        end

        case res
          when Net::HTTPSuccess
            puts "Crossbar::HTTP - Response Body: #{res.body}" if self.verbose
            return JSON.parse(res.body, {:symbolize_names => true})
          else
            raise "Crossbar::HTTP - Code: #{res.code}, Error: #{res.message}"
        end
      end
    end
  end
end