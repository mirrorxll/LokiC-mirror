# frozen_string_literal: true

require_relative 'main_endpoint/job.rb'
require_relative 'main_endpoint/job_item.rb'
require_relative 'main_endpoint/lead.rb'
require_relative 'main_endpoint/story.rb'

module Pipeline
  # assembling main endpoints
  module MainEndpoint
    include Job
    include JobItem
    include Lead
    include Story
  end
end