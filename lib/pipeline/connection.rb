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

      Faraday::Connection.new(endpoint, headers)
    end
  end
end
