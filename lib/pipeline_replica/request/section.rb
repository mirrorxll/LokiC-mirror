# frozen_string_literal: true

module PipelineReplica
  module Request
    # request return job or nil
    module Section
      def get_sections
        @pl_replica.query(sections_query).to_a
      end

      private

      def sections_query
        'SELECT id, name FROM story_sections;'
      end
    end
  end
end
