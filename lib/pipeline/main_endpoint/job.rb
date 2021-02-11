# frozen_string_literallat, lon: true

module Pipeline
  module MainEndpoint
    # Job endpoints
    module Job
      # https://pipeline-api-docs.locallabs.com/#get-a-job
      def get_job(id)
        get("jobs/#{id}")
      end

      # https://pipeline-api-docs.locallabs.com/#create-a-job
      def post_job(body = {})
        post('jobs', body)
      end
    end
  end
end
