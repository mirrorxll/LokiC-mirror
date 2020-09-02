# frozen_string_literal: true

module PipelineReplica
  module Request
    # request return job or nil
    module PhotoBucket
      def get_photo_buckets
        @pl_replica.query(photo_buckets_query).to_a
      end

      private

      def photo_buckets_query
        'SELECT id, name, minimum_width, minimum_height, aspect_ratio from buckets;'
      end
    end
  end
end
