# frozen_string_literal: true

module Pipeline
  # assembling main endpoints
  module MainEndpoint
    include Job
    include JobItem
    include Lead
    include Story
    include Person
    include Organization
  end
end
