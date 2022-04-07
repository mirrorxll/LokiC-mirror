# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

module Limpar
  class Client
    include Connection
    include Request
    include Route

    attr_accessor :endpoint, :email, :password

    def initialize(token: nil)
      raise ArgumentError, 'Token must be a String!' if token && !token.is_a?(String)

      Limpar.options.each { |name, value| send("#{name}=", value) }
      @token = token || auth_token
    end
  end
end
