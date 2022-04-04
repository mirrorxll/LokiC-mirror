# frozen_string_literal: true

module MiniLokiC
  module Population
    module Publications
      # get publications by client id
      class StateLevel < Publications::Base
        include Query::StateLevel

        def initialize(states = [])
          super()

          @query =
            if states.any?
              @client_ids = client_ids(states)
              pubs_query
            else
              all_state_lvl_pubs_query
            end
        end

        def pubs
          get(@query)
        end

        private

        def client_ids(states)
          ids_states = @route.query(clients_ids_states_query).to_a
          st_lvl_states = ids_states.map { |lvl| lvl['state'] }

          unless (states & st_lvl_states).count.eql?(states.count)
            states.each do |state|
              next if st_lvl_states.include?(state)

              raise ArgumentError, "You passed wrong state name \"#{state}\" to STATE-LEVEL publications' method"
            end
          end

          ids_states = ids_states.keep_if { |mm| states.include?(mm['state']) }
          ids_states.map { |row| row['client_id'] }.join(',')
        end
      end
    end
  end
end
