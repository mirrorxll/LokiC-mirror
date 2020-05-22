# frozen_string_literal: true

module PipelineReplica
  module Request
    # request return job or nil
    module Tag
      def get_tags
        @pl_replica.query(get_tags_query).to_a
      end

      private

      def get_tags_query
        'SELECT id, name FROM story_tags;'
      end
    end
  end
end
