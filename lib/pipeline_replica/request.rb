# frozen_string_literal: true

Dir["#{__dir__}/request/*.rb"].each { |file| require_relative file }

module PipelineReplica
  # requests to PL
  module Request
    include ClientsPublicationsTag
    include Job
    include JobItem
    include Organization
    include PhotoBucket
    include Section
  end
end
