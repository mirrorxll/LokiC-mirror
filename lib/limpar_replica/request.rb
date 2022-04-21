# frozen_string_literal: true

Dir["#{__dir__}/request/*.rb"].each { |file| require_relative file }

module LimparReplica
  # requests to LP-replica
  module Request
    include Topic
  end
end
