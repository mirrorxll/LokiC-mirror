module PipelineReplica
  module Request
    # request return job or nil
    module ContentType
      def get_content_types
        @pl_replica.query(get_content_types_query).to_a
      end

      private

      def get_content_types_query
        'SELECT * FROM content_types;'
      end
    end
  end
end
