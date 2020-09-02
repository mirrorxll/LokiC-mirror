# frozen_string_literal: true

module Samples
  module Export
    module LeadStoryPost
      private

      def lead_story_post(sample, client_tags)
        output = sample.output
        client = sample.client
        publication = sample.publication
        tag = client_tags.find_by(client: client).tag

        lead_id = lead_post(sample, output.headline, publication)
        story_post(lead_id, output, client, publication, tag, sample.published_at)
      end

      def lead_post(sample, headline, publication)
        exp_config = sample.export_configuration
        timestamp = "#{Date.today}.#{Time.now.to_i}"
        job_item_id = job_item_id(exp_config, publication)

        params = {
          name: "#{headline} -- [#{exp_config.id}.#{sample.id}::#{timestamp}]",
          job_item_id: job_item_id,
          sub_type_id: 594,
          community_ids: [publication.pl_identifier]
        }

        response = @pl_client.post_lead_safe(params)
        raise "Post lead failed. Status: #{response.status}." if (response.status / 100) != 2

        JSON.parse(response.body)['id']
      end

      def story_post(lead_id, output, client, publication, tag, publication_date)
        published = true
        story_tag_ids = tag.pl_identifier
        author = client.author.name
        published_at = published_at(publication_date)
        bucket_id = @story_type.photo_bucket.pl_identifier
        story_section_ids = client.sections.map { |section| section[:pl_identifier] }

        params = {
          community_id: publication.pl_identifier,
          lead_id: lead_id,
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

        response = @pl_client.post_story_safe(params)

        if (response.status / 100) != 2
          @pl_client.delete_lead(lead_id)
          raise "Post story failed. Status: #{response.status}."
        end

        JSON.parse(response.body)['id']
      end
    end
  end
end
