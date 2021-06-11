# frozen_string_literal: true

require_relative 'publications/base.rb'
require_relative 'publications/by_clients_state.rb'
require_relative 'publications/by_org_client_id.rb'
require_relative 'publications/metric_media.rb'
require_relative 'publications/from_lat_lon.rb'
require_relative 'publications/state_level.rb'

module MiniLokiC
  module Population
    module Publications
      module_function

      # The methods are returned an array of hashes like this:
      # [{"id"=>2072, "name"=>"Hawkeye Reporter", "client_id"=>158, "client_name"=>"MM - Iowa "}]

      # Publications.all -- all MB, MM, LGIS non-state-level publications
      # Publications.by(clients: nil, state: nil) -- ['MB', 'MM', 'LGIS'] publications for special state.
      #   e.g: Publications.by(clients: ['MM', 'MB'], state: 'Iowa') -- all non-state-level publications for MM - Iowa and MB in Iowa
      #        Publications.by(clients: ['MB']) -- all MB publications
      # Publications.mm_by_state(*state) -- all MM publications in passed states
      #   e.g: Publications.mm_by_state('Iowa', 'Texas') -- all non-state-level publications in Iowa and Texas
      # Publications.from_lat_lon(latitude, longitude, *clients) -- non-state-level publications from lat/lon coords.
      #   e.g: Publications.from_lat_lon(123, -321, 'MM') -- all MM publications by passed coords
      #   e.g: Publications.from_lat_lon(123, -321, 'MM', 'MB') -- all MM and MB publications in passed coords
      #   e.g: Publications.from_lat_lon(123, -321) -- ALL PUBLICATIONS IN PASSED COORDS. ! ATTENTION ! IT CAN BE RETURNED CLIENTS-PUBLICATION THAT WE USUALY NOT USE
      # Publications.by_org_client_id(org_id, *client_ids) -- non-state-level publications by organization_id
      #   e.g: Publications.by_org_client_id(647534066, 91, 120) -- non-state-level publications by organization_id for LGIS and MB
      # Publications.mm_excluding_states(org_id, *states) -- non-state-level MM publications by organization_id and state
      #   e.g: Publications.mm_excluding_states(647534066, 'Iowa', 'Texas') - non-state-level publications by organization_id for MM - Iowa and MM - Texas
      # Publications.mm_by_org_id(org_id, *states) - The same us method above (alias of mm_excluding_states)
      # Publications.all_state_lvl -- all state-level-publications
      # Publications.state_lvl_by(*states) -- all state-level publications by passed states
      #   e.g: Publications.state_lvl_by('Iowa', 'Illinois') - state-level publications for MM - Iowa and LGIS

      def all
        ByClientsState.new.pubs
      end

      def by(clients: nil, state: nil)
        return [] if [clients, state].all?(&:blank?)

        ByClientsState.new(clients, state).pubs
      end

      def from_lat_lon(latitude, longitude, *clients)
        FromLatLon.new(latitude, longitude, clients.flatten).pubs
      end

      def by_org_client_id(org_id, *client_ids)
        ByOrgClientId.new(org_id, client_ids.flatten).pubs
      end

      def mm_by_org_id(org_id, *states)
        states = states.reject { |state| state.downcase.in?(['illinois', 'district of columbia']) }
        return [] if states.empty?

        MetricMedia.new(org_id: org_id, states: states.flatten).pubs
      end

      def mm_excluding_states(org_id, *states)
        mm_by_org_id(org_id, *states)
      end

      def mm_by_state(*states)
        return [] if states.empty?

        MetricMedia.new(states: states.flatten).pubs
      end

      # STATE LEVEL PUBS
      def all_state_lvl
        StateLevel.new.pubs
      end

      def state_lvl_by(*states)
        states = states.reject { |state| state.downcase.eql?('district of columbia') }
        return [] if states.empty?

        StateLevel.new(states.flatten).pubs
      end
    end
  end
end
