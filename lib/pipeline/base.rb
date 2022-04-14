# frozen_string_literal: true

module Pipeline
  class Base
    include Connection
    include Request

    attr_reader :environment
    attr_accessor :token, :endpoint
  end
end
