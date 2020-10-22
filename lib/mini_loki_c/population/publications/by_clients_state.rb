# frozen_string_literal: true

require_relative 'by_clients_state/query.rb'

module MiniLokiC
  module Population
    module Publications
      # get publications by client id
      class ByClientsState < Publications::Base
        def initialize(clients = %w[MM MB LGIS], state = nil)
          super()
          @clients = clients
          @state = state
        end

        def pubs
          publications = []
          if @clients.include?('LGIS') && ['Illinois', nil].include?(@state)
            publications += get(lgis_query, false)
          end

          if @clients.include?('MB')
            publications += get(mb_query, false)
          end

          if @clients.include?('MM')
            publications += get(mm_query, false)
          end

          publications
        end
      end
    end
  end
end
