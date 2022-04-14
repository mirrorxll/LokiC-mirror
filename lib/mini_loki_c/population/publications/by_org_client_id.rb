# frozen_string_literal: true

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
