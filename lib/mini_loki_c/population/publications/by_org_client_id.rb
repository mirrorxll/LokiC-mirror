# frozen_string_literal: true

require_relative 'query/by_org_client_id.rb'

module MiniLokiC
  module Population
    module Publications
      # get publications by client id
      class ByOrgClientId < Publications::Base
        include Query::ByOrgClientId

        def initialize(org_id, client_ids = [])
          super()
          @org_id = org_id
          @client_ids = client_ids.join(',')
        end

        def pubs
          get(pubs_query)
        end
      end
    end
  end
end
