# frozen_string_literal: true

module Pipeline
  module MainEndpoint
    # Lead endpoints
    module Lead
      # https://pipeline-api-docs.locallabs.com/#get-a-lead
      def get_lead(id)
        get("leads/#{id}")
      end

      # https://pipeline-api-docs.locallabs.com/#create-a-lead
      def post_lead(body = {})
        post('leads', body)
      end

      # https://pipeline-api-docs.locallabs.com/#update-a-lead
      def update_lead(id, body = {})
        put("leads/#{id}", body)
      end

      # https://pipeline-api-docs.locallabs.com/#delete-a-lead
      def delete_lead(id)
        delete("leads/#{id}")
      end
    end
  end
end
