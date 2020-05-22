# frozen_string_literal: true

module Stories
  class Export
    def initialize(pl_client, story_type, options)
      @pl_client = pl_client
      @pl_replica_client = PipelineReplica[pl_client.environment]
      @story_type = story_type
      @options = options
    end

    def export!
      @options[:sample_ids] ? by_ids : all
    end

    private

    def by_ids
      stories = @story_type.iteration.samples.where(id: @options[:sample_ids])

      stories.each do |story|
        publication = story.publication
        job_item_id = job_item(publication)

        exp_config = story.export_configuration
        output = story.output
        lead_name = "#{output.headline} -- [#{exp_config.id}.#{story.id}::#{Date.today.to_s}.#{Time.now.to_i}]"

        lead_response = @pl_client.post_lead(
          {
            job_item_id: job_item_id,
            name: lead_name,
            sub_type_id: 594,
            community_ids: [publication.pl_identifier]
          }
        )

        lead = JSON(lead_response.body)
        published_at = DateTime.now.strftime('%Y-%m-%dT%H:%M:%S%:z')
        story_tag_ids = @story_type.tag.pl_identifier
        story_section_ids = story_section_ids_by(publication.client.name)
        bucket_id = @story_type.photo_bucket.pl_identifier
        published = true
        author = publication.client.name.eql?('The Record') ? 'Record Inc News Service' : 'Metric Media News Service'
        output = story.output

        story_response = @pl_client.post_story(
          {
            community_id: publication.pl_identifier,
            lead_id: lead['id'],
            headline: output.headline,
            teaser: output.teaser,
            body: output.body,
            published_at: published_at,
            organization_ids: [],
            author: author,
            story_section_ids: story_section_ids,
            story_tag_ids: [story_tag_ids],
            published: published,
            bucket_id: bucket_id
          }
        )
      end
    end

    def job_item(publication)
      job = @pl_replica_client.get_job(publication.pl_identifier)

      job_id =
        if job
          job['id']
        else
          job_name = "#{publication.name} - HLE"
          response = @pl_client.post_job(name: job_name, project_id: publication.pl_identifier)
          JSON.parse(response.body)['id']
        end

      job_item = @pl_replica_client.get_job_item(publication.name, @story_type.name, job_id)

      if job_item
        job_item['id']
      else
        job_item_name = "#{publication} - #{@story_type.name} HLE"
        response = @pl_client.post_job_item(name: job_item_name, job_id: job_id, content_type: 'hle', bucket_ids: [@@story_type.photo_bucket.pl_identifier], twitter_disabled: true, org_required: false)
        JSON.parse(response.body)['id']
      end
    end

    def story_section_ids_by(client_name)
      if client_name.eql?('LGIS')
        [2, 16]
      elsif client_name.eql?('The Record') || client_name.start_with?('MM - ')
        [16]
      else
        [2]
      end
    end

    def all

    end
  end
end
