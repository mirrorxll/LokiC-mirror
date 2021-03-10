# frozen_string_literal: true

require_relative 'connection.rb'
require_relative 'request.rb'

module Pipeline
  class Base
    include Connection
    include Request

    attr_reader :environment
    attr_accessor :token, :endpoint
  end
end
