# frozen_string_literal: true

module LimparReplica
  module Request
    module Topic
      def get_topics
        @lp_replica.query(topics_query).to_a
      end

      private

      def topics_query
        'SELECT id, kind, description, kinds, deleted_at FROM topics;'
      end
    end
  end
end
