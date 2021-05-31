# frozen_string_literal: true

require_relative 'publications/base.rb'
require_relative 'publications/by_clients_state.rb'
require_relative 'publications/by_org_client_id.rb'
require_relative 'publications/metric_media.rb'
require_relative 'publications/from_lat_lon.rb'
require_relative 'publications/state_level.rb'

module MiniLokiC
  module Population
    # The methods are returned an array of hashes like this:
    # [{"id"=>2072, "name"=>"Hawkeye Reporter", "client_id"=>158, "client_name"=>"MM - Iowa "}]
    module Publications
      module_function

      def all
        ByClientsState.new.pubs
      end

      def by(clients: nil, state: nil)
        ByClientsState.new(clients, state).pubs
      end

      def from_lat_lon(latitude, longitude, *clients)
        FromLatLon.new(latitude, longitude, clients.flatten).pubs
      end

      def by_org_client_id(org_id, *client_ids)
        ByOrgClientId.new(org_id, client_ids.flatten).pubs
      end

      def mm_by_org_id(org_id, *states)
        MetricMedia.new(org_id: org_id, states: states.flatten).pubs
      end

      def mm_excluding_states(org_id, *states)
        mm_by_org_id(org_id, *states)
      end

      def mm_by_state(*state)
        MetricMedia.new(states: state.flatten).pubs
      end

      # STATE LEVEL PUBS
      def all_state_lvl
        StateLevel.new.pubs
      end

      def state_lvl_by_org_client_id(org_id, *client_ids)
        StateLevel.new(org_id, client_ids.flatten).pubs
      end
    end
  end
end
