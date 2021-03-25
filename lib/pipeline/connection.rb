# frozen_string_literal: true

require 'faraday'

module Pipeline
  # initialize faraday connection
  module Connection
    private

    def connection
      headers = {
        headers: {
          'Authorization' => token,
          'Content-Type' => 'application/json',
          'X-Force-Update' => 'true'
        }
      }
      retry_options = {
        exceptions: [Faraday::ServerError, Faraday::ConnectionFailed],
        max: 6,
        interval: 1,
        backoff_factor: 2
      }

      Faraday::Connection.new(endpoint, headers) do |c|
        c.response :raise_error
        c.request :retry, retry_options
      end
    end
  end
end
