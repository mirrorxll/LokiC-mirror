# frozen_string_literal: true

require_relative 'connection.rb'
require_relative 'request.rb'

module Pipeline
  class Base
    include Connection
    include Request

    attr_reader :environment
    attr_accessor :token, :endpoint

    private

    def method_missing(symbol, *args)
      method = symbol.to_s
      super unless method.end_with?('_safe')

      method.delete_suffix!('_safe')
      sleep = 1

      begin
        send(method, *args)
      rescue Faraday::ServerError => e
        raise e if sleep > 127

        sleep(sleep)
        sleep *= 2
        retry
      end
    end

    def respond_to_missing?(*several_variants)
      several_variants.all? { |v| v.to_s.end_with?('_safe') } || super
    end
  end
end
