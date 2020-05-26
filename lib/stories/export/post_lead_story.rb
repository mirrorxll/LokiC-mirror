# frozen_string_literal: true

module Stories
  module PostLeadStory
    private

    TIMES_BY_WEEKDAY = {
      0 => '7:00-10:00',  # "Sunday"
      1 => '10:00-12:00', # "Monday"
      2 => '7:00-10:00',  # "Tuesday"
      3 => '7:00-10:00',  # "Wednesday"
      4 => '7:00-10:00',  # "Thursday"
      5 => '7:00-10:00',  # "Friday"
      6 => '8:30-9:30'    # "Saturday"
    }.freeze

    def post_lead_story(story)
      publication = story.publication
      output = story.output

      params = lead_params(story, publication, output.headline)
      lead_response = @pl_client.post_lead_safe(params).body
      lead_response = JSON.parse(lead_response)

      params = story_params(lead_response, story, publication, output)
      story_response = @pl_client.post_story_safe(params).body
      story_response = JSON.parse(story_response)

      organization_ids = story.organization_ids.delete('[ ]').split(',')
      @pl_client.update_story(story_response['id'], organization_ids: organization_ids )
      story.update("pl_#{@pl_client.environment}_id" => story_response['id'])
    end

    def lead_params(story, publication, headline)
      exp_config = story.export_configuration
      job_item_id = job_item_id(exp_config, publication)
      timestamp = "#{Date.today}.#{Time.now.to_i}"

      {
        name: "#{headline} -- [#{exp_config.id}.#{story.id}::#{timestamp}]",
        job_item_id: job_item_id,
        sub_type_id: 594,
        community_ids: [publication.pl_identifier]
      }
    end

    def story_params(lead_response, story, publication, output)
      published_at = published_at(story.published_at)
      story_tag_ids = @story_type.tag.pl_identifier
      story_section_ids = publication.client.sections.map { |section| section[:pl_identifier] }
      bucket_id = @story_type.photo_bucket.pl_identifier
      published = true
      author = publication.client.author.name

      {
        community_id: publication.pl_identifier,
        lead_id: lead_response['id'],
        organization_ids: [],
        headline: output.headline,
        teaser: output.teaser,
        body: output.body,
        published_at: published_at,
        author: author,
        story_section_ids: story_section_ids,
        story_tag_ids: [story_tag_ids],
        published: published,
        bucket_id: bucket_id
      }
    end

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

      response = JSON.parse(response.body)
      response['id'] || (raise StandardError, 'Job was not created.')
    end

    def create_job_item(job_id, publication)
      response = @pl_client.post_job_item(
        job_id: job_id,
        name: "#{publication.name} - #{@story_type.name} HLE",
        content_type: 'hle',
        bucket_ids: photo_bucket,
        twitter_disabled: true,
        org_required: false
      )

      response = JSON.parse(response.body)
      response['id'] || (raise StandardError, 'Job Item was not created.')
    end

    def photo_bucket
      @pl_client.environment.eql?(:production) ? [@story_type.photo_bucket] : []
    end

    def published_at(date)
      datetime_start =
        Time.parse("#{date} #{TIMES_BY_WEEKDAY[date.wday].split('-')[0]} EST")
      datetime_end =
        Time.parse("#{date} #{TIMES_BY_WEEKDAY[date.wday].split('-')[1]} EST")
      datetime =
        (datetime_end.to_f - datetime_start.to_f) * rand + datetime_start.to_f

      Time.at(datetime).strftime('%Y-%m-%dT%H:%M:%S%:z')
    end
  end
end
