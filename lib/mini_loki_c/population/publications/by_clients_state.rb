# frozen_string_literal: true

require_relative 'by_clients_state/query.rb'

module MiniLokiC
  module Population
    module Publications
      # get publications by client id
      class ByClientsState < Publications::Base
        def initialize(clients = nil, state = nil)
          super()
          @clients = clients || %w[MM MB LGIS]
          @state = state
        end

        def pubs
          publications = []
          publications += get(lgis_query, false) if @clients.include?('LGIS') && ['Illinois', nil].include?(@state)
          publications += get(mb_query, false) if @clients.include?('MB')
          publications += get(mm_query, false) if @clients.include?('MM')

          publications
        end
      end
    end
  end
end
