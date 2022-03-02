# frozen_string_literal: true

module Limpar
  module Request
    def get(path, params = nil)
      request(:get, path, params: params)
    end

    # HTTP Post request
    def post(path, body = nil)
      request(:post, path, body: body)
    end

    # HTTP Put/Patch request
    def put(path, body = nil)
      request(:put, path, body: body)
    end
    alias patch put

    # HTTP Delete request
    def delete(path, params = {})
      request(:delete, path, params: params)
    end

    def request(method, path, params: nil, body: nil)
      connection.send(method) do |req|
        req.path = path
        req.params = params if params
        req.body = body.to_json if body
      end
    end
  end
end
