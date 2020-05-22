# frozen_string_literal: true

Dir["#{__dir__}/request/*.rb"].each { |file| require_relative file }

module PipelineReplica
  # requests to PL
  module Request
    include Job
    include JobItem
    include ClientPublication
    include Section
    include Tag
    include PhotoBucket
  end
end
