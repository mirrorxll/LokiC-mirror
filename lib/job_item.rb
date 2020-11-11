# frozen_string_literal: true

class JobItem
  def self.find_or_create(exp_config, environment)
    new(environment).send(:f_o_cr, exp_config)
  end

  private

  def initialize(environment)
    @environment = environment
    @pl_client = Pipeline[environment]
    @pl_r_client = PipelineReplica[environment]
  end

  # find or create job_item
  def f_o_cr(exp_config)
    story_type = exp_config.story_type
    publication = exp_config.publication
    p_bucket = exp_config.photo_bucket

    job = @pl_r_client.get_job(publication.pl_identifier)
    job_id = job ? job['id'] : create_job(publication)
    job_item = @pl_r_client.get_job_item(job_id, story_type.name, publication.name)
    job_item_id = job_item ? job_item['id'] : create_job_item(job_id, story_type, publication, p_bucket)

    exp_config.update("#{@environment}_job_item".to_sym => job_item_id)

    @pl_r_client.close
    job_item_id
  end

  def create_job(publication)
    response = @pl_client.post_job_safe(
      name: "#{publication.name} - HLE",
      project_id: publication.pl_identifier
    )

    JSON.parse(response.body)['id']
  end

  def create_job_item(job_id, story_type, publication, p_bucket)
    photo_bucket = @environment.eql?(:production) ? [p_bucket.pl_identifier] : []

    response = @pl_client.post_job_item_safe(
      job_id: job_id,
      name: "#{publication.name} - #{story_type.name} HLE",
      content_type: 'hle',
      bucket_ids: photo_bucket,
      twitter_disabled: true,
      org_required: false
    )

    JSON.parse(response.body)['id']
  end
end
