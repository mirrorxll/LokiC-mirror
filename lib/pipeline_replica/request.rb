# frozen_string_literal: true

Dir["#{__dir__}/request/*.rb"].each { |file| require_relative file }

module PipelineReplica
  # requests to PL-replica
  module Request
    include Job
    include JobItem
    include Organization
    include ClientsPublicationsTags
    include Sections
    include PhotoBuckets
    include User
    include Agency
    include Opportunity
    include OpportunityType
    include ContentType
  end
end
