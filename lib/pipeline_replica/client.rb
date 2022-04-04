# frozen_string_literal: true

module PipelineReplica
  class Client < Connection
    include Request

    def initialize(environment)
      raise ArgumentError unless %i[staging production].include?(environment)

      super
    end
  end
end
