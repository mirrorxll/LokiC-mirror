# frozen_string_literal: true

module Samples
  module Export
    module LeadStoryPost
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

      def lead_story_post(sample, pl_r_client)
        exp_config = sample.export_configuration

        lead_id = lead_post(sample, exp_config)
        story_id = story_post(lead_id, sample, exp_config, pl_r_client)

        sample.update(
          @pl_lead_id_key => lead_id,
          @pl_story_id_key => story_id,
          exported_at: DateTime.now
        )
      end

      def lead_post(sample, exp_config)
        publication = exp_config.publication
        name = "#{sample.headline} -- [#{exp_config.id}."\
               "#{sample.id}::#{Date.today}.#{Time.now.to_i}]"

        params = {
          name: name,
          job_item_id: exp_config["#{@environment}_job_item"],
          sub_type_id: 594,
          community_ids: [publication.pl_identifier]
        }

        raw_response = @pl_client.post_lead_safe(params)
        response = JSON.parse(raw_response.body)

        if (raw_response.status / 100) != 2
          raise Samples::LeadPostError, response.to_json

          # raise Samples::LeadPostError,
          #       "Post lead failed. Status: #{response.status}.\n"\
          #       "Why? > #{response.body}."
        end

        response['id']
      end

      def published_at(date)
        datetime_to_f = lambda do |dt, pos|
          Time.parse("#{dt} #{TIMES_BY_WEEKDAY[dt.wday][pos]} EST").to_f
        end

        start = datetime_to_f.call(date, 0)
        finish = datetime_to_f.call(date, 1)
        publish_on = (finish - start) * rand + start

        Time.at(publish_on).strftime('%Y-%m-%dT%H:%M:%S%:z')
      end

      def story_post(lead_id, sample, exp_config, pl_r_client)
        author = sample.client.author.name
        client = sample.client
        publication = exp_config.publication
        story_tag_ids = exp_config.tag.pl_identifier
        photo_bucket_id = exp_config.photo_bucket.pl_identifier
        published_at = published_at(sample.published_at)
        story_section_ids = client.sections.map { |section| section[:pl_identifier] }

        sample_org_ids = sample.organization_ids.delete('[ ]').split(',')
        active_org_ids = pl_r_client.get_active_organization_ids(sample_org_ids)

        params = {
          community_id: publication.pl_identifier,
          lead_id: lead_id,
          organization_ids: active_org_ids,
          headline: sample.headline,
          teaser: sample.teaser,
          body: sample.body,
          published_at: published_at,
          author: author,
          story_section_ids: story_section_ids,
          story_tag_ids: [story_tag_ids],
          published: true,
          bucket_id: photo_bucket_id
        }

        raw_response = @pl_client.post_story_safe(params)
        response = JSON.parse(raw_response.body)

        # if story organization ids are broken,
        # it'll try to post story without organization ids
        if (raw_response.status / 100) != 2 && response.any?(['organizations', 'is invalid'])
          @report_semaphore.synchronize { @report[:errors][:stories] << response }

          params['organization_ids'] = []
          raw_response = @pl_client.post_story_safe(params)
          response = JSON.parse(raw_response.body)
        end

        if (raw_response.status / 100) != 2
          @pl_client.delete_lead_safe(lead_id)
          raise Samples::StoryPostError, response.to_json

          # raise Samples::StoryPostError,
          #       "Post story failed. Status: #{response.status}.\n"\
          #       "Why? > #{response.body}."
        end

        response['id']
      end
    end
  end
end
