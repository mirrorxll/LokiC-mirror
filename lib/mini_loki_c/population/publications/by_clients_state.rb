# frozen_string_literal: true

module MiniLokiC
  module Population
    module Publications
      # get publications by client id
      class ByClientsState < Publications::Base
        include Query::ByClientsState

        def initialize(clients = nil, state = nil)
          super()
          @clients = clients || %w[MM MB LGIS]
          @state = state
        end

        def pubs
          publications = []
          publications += get(mb_query, false)   if @clients.include?('MB')
          publications += get(mm_query, false)   if @clients.include?('MM')
          publications += get(lgis_query) if @clients.include?('LGIS') && ['Illinois', nil].include?(@state)

          publications
        end
      end
    end
  end
end
