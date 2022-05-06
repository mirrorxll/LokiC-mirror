# frozen_string_literal: true

module Limpar
  module Connection
    private

    def auth_token
      response = Faraday.post("#{endpoint}/authenticate") do |r|
        r.headers = { 'Content-Type': 'application/json' }
        r.body = { email: email, password: password }.to_json
      end
      @token = JSON.parse(response.body)['token']

      "Bearer #{@token}"
    end

    def connection
      request = {
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => @token
        }
      }

      retry_options = {
        exceptions: [Faraday::UnauthorizedError],
        max: 6,
        interval: 2,
        backoff_factor: 2,
        retry_block: proc { |env| env.request_headers['Authorization'] = auth_token }
      }

      Faraday::Connection.new(endpoint, request) do |c|
        c.request :retry, retry_options
        c.response :raise_error
        #c.response :logger
      end
    end
  end
end
