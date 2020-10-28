# frozen_string_literal: true

module Pipeline
  module MainEndpoint
    # Job item endpoints
    module JobItem
      # https://pipeline-api-docs.locallabs.com/#create-a-job-item
      def post_job_item(body = {})
        post('job_items', body)
      end
    end
  end
end
