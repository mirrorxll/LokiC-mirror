# frozen_string_literal: true

require_relative 'request/job.rb'
require_relative 'request/job_item.rb'

module PipelineReplica
  # requests to PL
  module Request
    include Job
    include JobItem
  end
end
