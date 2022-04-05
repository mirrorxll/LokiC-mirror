# frozen_string_literal: true

module Samples
  module Export
    module LeadStoryPost
      private

      TIMES_BY_WEEKDAY = [
        %w[7:00 19:30], # "Sunday"
        %w[7:00 19:30], # "Monday"
        %w[7:00 19:30], # "Tuesday"
        %w[7:00 19:30], # "Wednesday"
        %w[7:00 19:30], # "Thursday"
        %w[7:00 13:00], # "Friday"
        %w[7:00 13:00]  # "Saturday"
      ].freeze

      def lead_story_post(sample, st_opportunities)
        exp_config = sample.export_configuration

        lead_id = lead_post(sample, exp_config, st_opportunities)
        story_id = story_post(lead_id, sample, exp_config)

        sample.update!(
          @pl_lead_id_key => lead_id,
          @pl_story_id_key => story_id,
          exported_at: DateTime.now
        )
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

      def sections(story_type, publication)
        clients_publications_tags = story_type.clients_publications_tags.to_a

        cl_pub_tg = clients_publications_tags.find { |cpt| cpt.publication.eql?(publication) }
        return cl_pub_tg.sections if cl_pub_tg

        aggregated_cpt = clients_publications_tags.select do |cpt|
          cpt.publication.nil? || cpt.publication.name.in?(@pub_aggregate_names)
        end

        aggregated_cpt.find do |cpt|
          cpt.client.publications.include?(publication)
        end.sections
      end

      def lead_post(sample, exp_config, st_opportunities)
        publication = exp_config.publication
        name = "#{sample.headline} -- [#{exp_config.id}."\
               "#{sample.id}::#{Date.today}.#{Time.now.to_i}]"
        st_opportunity = st_opportunities.find_by(publication: publication)

        params = {
          name: name,
          job_item_id: exp_config["#{@environment}_job_item"],
          sub_type_id: 594,
          community_ids: [publication.pl_identifier],
          opportunity_id: st_opportunity&.opportunity&.id,
          opportunity_type_id: st_opportunity&.opportunity_type&.id,
          content_type_id: st_opportunity&.content_type&.id
        }

        response = @pl_client.post_lead(params)
        lead = JSON.parse(response.body)
        (raise StandardError, lead.to_s) unless lead['id']

        lead['id']
      rescue StandardError => e
        raise Samples::LeadPostError, "[ LeadPostError ] -> #{e.message} at #{e.backtrace.first}"
      end

      def story_post(lead_id, sample, exp_config)
        publication = exp_config.publication
        story_tag_ids = exp_config.tag.name.eql?('_Blank') ? [] : [exp_config.tag.pl_identifier]
        photo_bucket_id = exp_config.photo_bucket&.pl_identifier
        story_section_ids = sections(sample.story_type, publication).map(&:pl_identifier)
        published_at = published_at(sample.published_at.to_date)
        sample_org_ids = sample.organization_ids.delete('[ ]').split(',')

        params = {
          community_id: publication.pl_identifier,
          lead_id: lead_id,
          organization_ids: [],
          headline: sample.headline,
          teaser: sample.teaser,
          body: sample.body,
          published_at: published_at,
          author: publication.name,
          story_section_ids: story_section_ids,
          story_tag_ids: story_tag_ids,
          published: true,
          bucket_id: photo_bucket_id
        }

        response = @pl_client.post_story(params)
        story = JSON.parse(response.body)
        (raise StandardError, story.to_s) unless story['id']

        @pl_client.update_story(story['id'], organization_ids: sample_org_ids)
        sample.update!(published_at: published_at)

        story['id']
      rescue StandardError => e
        @pl_client.delete_lead(lead_id)
        raise Samples::StoryPostError, "[ StoryPostError ] -> #{e.message} at #{e.backtrace.first}".gsub('`', "'")
      end
    end
  end
end
