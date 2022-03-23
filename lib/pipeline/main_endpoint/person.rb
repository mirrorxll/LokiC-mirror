# frozen_string_literal: true

module Pipeline
  module MainEndpoint
    # LimparPeople endpoints
    module Person
      # https://pipeline-api-docs.locallabs.com/#get-a-person
      def get_person(id)
        get("people/#{id}")
      end

      # https://pipeline-api-docs.locallabs.com/#create-a-person
      def post_person(body = {})
        post('people', body)
      end

      # https://pipeline-api-docs.locallabs.com/#update-a-person
      def update_person(id, body = {})
        put("people/#{id}", body)
      end
    end
  end
end
