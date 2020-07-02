# frozen_string_literal: true

module Samples
  module JobItem
    private

    def job_item_id(exp_config, publication)
      return exp_config[@job_item_key] if exp_config[@job_item_key]

      job = @pl_replica_client.get_job(publication.pl_identifier)
      job_id = job ? job['id'] : create_job(publication)

      job_item = @pl_replica_client.get_job_item(job_id, @story_type.name, publication.name)
      job_item_id = job_item ? job_item['id'] : create_job_item(job_id, publication)

      exp_config.update(@job_item_key => job_item_id)

      job_item_id
    end

    def create_job(publication)
      response = @pl_client.post_job(
        name: "#{publication.name} - HLE",
        project_id: publication.pl_identifier
      )

      JSON.parse(response.body)['id']
    end

    def create_job_item(job_id, publication)
      photo_bucket =
        @pl_client.environment.eql?(:production) ? [@story_type.photo_bucket] : []

      response = @pl_client.post_job_item(
        job_id: job_id,
        name: "#{publication.name} - #{@story_type.name} HLE",
        content_type: 'hle',
        bucket_ids: photo_bucket,
        twitter_disabled: true,
        org_required: false
      )

      JSON.parse(response.body)['id']
    end
  end
end