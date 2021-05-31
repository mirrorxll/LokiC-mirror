# frozen_string_literal: true

require_relative 'query/state_level.rb'

module MiniLokiC
  module Population
    module Publications
      # get publications by client id
      class StateLevel < Publications::Base
        include Query::StateLevel

        def initialize(org_id = nil, client_ids = [])
          super()
          @org_id = org_id
          @client_ids = client_ids.join(',')
        end

        def pubs
          query = @org_id ? pubs_query : all_state_lvl_pubs_query

          get(query)
        end
      end
    end
  end
end
