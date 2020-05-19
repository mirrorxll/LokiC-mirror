# frozen_string_literal: true

module PipelineReplica
  module Request
    # request return job or nil
    module Job
      def job(pub_id)
        job_q = job_query(pub_id)
        @replica.query(job_q).to_a.last
      end

      private

      def job_query(pub_id)
        'SELECT name, id FROM jobs '\
        "WHERE project_id = #{pub_id} AND name LIKE '% HLE';"
      end
    end
  end
end
