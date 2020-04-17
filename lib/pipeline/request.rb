# frozen_string_literal: true

require 'faraday'

module Pipeline
  # methods make requests to PL
  module Request
    private

    # HTTP Get request
    def get(path, options = {})
      request(:get, path, options)
    end

    # HTTP Post request
    def post(path, options = {})
      request(:post, path, options)
    end

    # HTTP Put/Patch request
    def put(path, options = {})
      request(:put, path, options)
    end
    alias path put

    # HTTP Delete request
    def delete(path, options = {})
      request(:delete, path, options)
    end

    # common method for making HTTP requests
    def request(method, path, options)
      response = connection.send(method) do |req|
        req.path = path
        req.body = options.to_json unless options.empty?
      end

      response.body
    end
  end
end
