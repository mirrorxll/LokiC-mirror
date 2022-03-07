# frozen_string_literal: true

module PipelineReplica
  module Request
    # request return job or nil
    module Agency
      def get_agencies
        @pl_replica.query(get_agencies_query).to_a
      end

      private

      def get_agencies_query
        'SELECT * FROM agencies;'
      end
    end
  end
end
