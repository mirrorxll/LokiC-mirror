module PipelineReplica
  module Request
    # request return job or nil
    module OpportunityType
      def get_opportunity_types
        @pl_replica.query(get_opportunity_types_query).to_a
      end

      private

      def get_opportunity_types_query
        'SELECT * FROM opportunity_types;'
      end
    end
  end
end
