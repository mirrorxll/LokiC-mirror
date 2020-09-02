# frozen_string_literal: true

module PipelineReplica
  module Request
    module Job
      # request return job or nil
      def get_job(pub_id)
        job_q = job_query(pub_id)
        @pl_replica.query(job_q).to_a.last
      end

      private

      def job_query(pub_id)
        'SELECT id, name FROM jobs '\
        "WHERE project_id = #{pub_id} AND name LIKE '% HLE';"
      end
    end
  end
end
