# frozen_string_literal: true

module MiniLokiC
  module Population
    module Publications
      # connection to production PL database and
      # generation output to console
      class Base
        def initialize
          @route = PipelineReplica::Connection.new(:production).pl_replica
        end

        private

        def get(query, close_connection = true)
          publications = @route.query(query).to_a

          @route&.close if close_connection
          publications
        end
      end
    end
  end
end
