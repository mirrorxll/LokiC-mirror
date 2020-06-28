# frozen_string_literal: true

module Samples
  module ExportParameters
    private

    TIMES_BY_WEEKDAY = [
      %w[7:00 10:00],   # "Sunday"
      %w[10:00 12:00],  # "Monday"
      %w[7:00 10:00],   # "Tuesday"
      %w[7:00 10:00],   # "Wednesday"
      %w[7:00 10:00],   # "Thursday"
      %w[7:00 10:00],   # "Friday"
      %w[8:30 9:30]     # "Saturday"
    ].freeze

    def lead_params(story, publication, headline)
      exp_config = story.export_configuration
      timestamp = "#{Date.today}.#{Time.now.to_i}"
      job_item_id = job_item_id(exp_config, publication)

      {
        name: "#{headline} -- [#{exp_config.id}.#{story.id}::#{timestamp}]",
        job_item_id: job_item_id,
        sub_type_id: 594,
        community_ids: [publication.pl_identifier]
      }
    end

    def story_params(sample, lead_response, publication, tag, output)
      published = true
      story_tag_ids = tag.id
      author = publication.client.author.name
      published_at = published_at(sample.published_at)
      bucket_id = @story_type.photo_bucket.pl_identifier
      story_section_ids = publication.client.sections.map { |section| section[:pl_identifier] }

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

    def published_at(date)
      start = datetime_to_f(date, 0)
      finish = datetime_to_f(date, 1)
      publish_on = (finish - start) * rand + start

      Time.at(publish_on).strftime('%Y-%m-%dT%H:%M:%S%:z')
    end

    def datetime_to_f(date, position)
      Time.parse("#{date} #{TIMES_BY_WEEKDAY[date.wday][position]} EST").to_f
    end
  end
end
