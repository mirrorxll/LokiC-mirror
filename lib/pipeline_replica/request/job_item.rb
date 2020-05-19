# frozen_string_literal: true

module PipelineReplica
  module Request
    # request return job item or nil
    module JobItem
      def job_item(pub_name, job_descr, job_id)
        job_item_q = job_item_query(pub_name, job_descr, job_id)
        @replica.query(job_item_q).to_a.last
      end

      private

      def job_item_query(pub_name, job_descr, job_id)
        'SELECT name, id FROM job_items '\
        "WHERE name = #{(pub_name + ' - ' + job_descr + ' HLE').dump} AND "\
        "job_id = #{job_id};"
      end
    end
  end
end
