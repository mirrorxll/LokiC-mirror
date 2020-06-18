# frozen_string_literal: true

module MiniLokiC
  module Population
    module Publications
      # connection to production PL database and
      # generation output to console
      class Base
        def initialize
          @route =
            PipelineReplica::Connection.new(:production).pl_replica
        end

        def pubs
          get(pubs_query)
        end

        private

        def get(query)
          publications = @route.query(query).to_a
          publications.each { |p| p.delete('org_name') }
          @route&.close

          publications
        end
      end
    end
  end
end
