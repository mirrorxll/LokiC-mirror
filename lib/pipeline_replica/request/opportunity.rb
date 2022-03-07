# frozen_string_literal: true

module PipelineReplica
  module Request
    module Opportunity
      def get_opportunities
        @pl_replica.query(get_opportunities_query).to_a
      end

      def get_join_content_types
        @pl_replica.query(get_opportunities_query).to_a
      end

      def get_join_opportunity_type
        @pl_replica.query(get_join_opportunity_type_query).to_a
      end

      def get_join_publications
        @pl_replica.query(get_join_publications_query).to_a
      end

      private

      def get_opportunities_query
        'SELECT * FROM opportunities;'
      end

      def get_join_content_types_query
        'SELECT * FROM opportunities_content_types;'
      end

      def get_join_opportunity_type_query
        'SELECT * FROM opportunities_opportunity_types;'
      end

      def get_join_publications_query
        'SELECT * FROM opportunities_projects;'
      end
    end
  end
end
