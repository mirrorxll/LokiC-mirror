# frozen_string_literal: true

require_relative 'query/metric_media.rb'

module MiniLokiC
  module Population
    module Publications
      # get ММ publications
      class MetricMedia < Publications::Base
        include Query::MetricMedia

        def initialize(org_id: nil, states: nil)
          super()
          @org_id = org_id
          @client_ids = client_ids(states)
        end

        def pubs
          query = @org_id ? pubs_query : pubs_by_passed_states_query

          get(query)
        end

        private

        def client_ids(states)
          mm_ids_states = @route.query(ids_states_query).to_a
          mm_states = mm_ids_states.map { |mm| mm['state'] }

          if states.any? && !(states & mm_states).count.eql?(states.count)
            states.each do |state|
              next if mm_states.include?(state)

              raise ArgumentError, "You passed wrong state name \"#{state}\" to MM publications' method"
            end
          elsif states.any?
            mm_ids_states = mm_ids_states.keep_if { |mm| states.include?(mm['state']) }
          end

          mm_ids_states.map { |row| row['client_id'] }.join(',')
        end
      end
    end
  end
end
