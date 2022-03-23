# frozen_string_literal: true

module Pipeline
  module MainEndpoint
    # LimparOrganization endpoints
    module Organization
      # https://pipeline-api-docs.locallabs.com/#get-all-organizations
      def get_all_organizations(params = {})
        get('organizations', params)
      end
    end
  end
end
