# frozen_string_literal: true

module PipelineReplica
  module Request
    # request return job item or nil
    module JobItem
      def get_job_item(publication_name, story_type_name, job_id)
        job_item_q = get_job_item_query(publication_name, story_type_name, job_id)
        @pl_replica.query(job_item_q).to_a.last
      end

      private

      def get_job_item_query(publication_name, story_type_name, job_id)
        job_item = (publication_name + ' - ' + story_type_name + ' HLE').dump

        'SELECT id, name FROM job_items '\
        "WHERE name = #{job_item} AND job_id = #{job_id};"
      end
    end
  end
end
