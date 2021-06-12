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

      def lead_story_post(sample)
        exp_config = sample.export_configuration

        lead_id = lead_post(sample, exp_config)
        story_id = story_post(lead_id, sample, exp_config)

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

        response = @pl_client.post_lead(params)

        JSON.parse(response.body)['id']
      rescue StandardError => e
        raise Samples::LeadPostError, "[#{e.class}] -> #{e.message} at #{e.backtrace.first}"
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

      def story_post(lead_id, sample, exp_config)
        author = sample.publication.name
        client = sample.client
        publication = exp_config.publication
        story_tag_ids = exp_config.tag.name.eql?('_Blank') ? [] : [exp_config.tag.pl_identifier]
        photo_bucket_id = exp_config.photo_bucket.pl_identifier
        published_at = published_at(sample.published_at)
        story_section_ids = client.sections.map { |section| section[:pl_identifier] }
        sample_org_ids = sample.organization_ids.delete('[ ]').split(',')
        active_org_ids = []
        limit = 99

        sample_org_ids.each_slice(limit) do |ids|
          response = @pl_client.get_all_organizations(ids: ids, limit: limit)
          active_org_ids += JSON.parse(response.body).map { |org| org['id'] }
        end

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
          story_tag_ids: story_tag_ids,
          published: true,
          bucket_id: photo_bucket_id
        }

        begin
          response = @pl_client.post_story(params)
        rescue Faraday::UnprocessableEntityError
          params[:organization_ids] = []
          response = @pl_client.post_story(params)
        end

        JSON.parse(response.body)['id']
      rescue StandardError => e
        @pl_client.delete_lead(lead_id)
        raise Samples::StoryPostError, "[#{e.class}] -> #{e.message} at #{e.backtrace.first}".gsub('`', "'")
      end
    end
  end
end
