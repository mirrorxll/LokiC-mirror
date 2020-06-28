# frozen_string_literal: true

module Samples
  module PostLeadStory
    private

    def post_lead_story(sample, client_tags)
      output = sample.output
      publication = sample.publication
      tag = client_tags.find_by(client: publication.client).tag

      params = lead_params(sample, publication, output.headline)
      lead_response = @pl_client.post_lead_safe(params).body
      lead_response = JSON.parse(lead_response)

      params = story_params(sample, lead_response, publication, tag, output)
      story_response = @pl_client.post_story_safe(params).body
      story_pl_id = JSON.parse(story_response)['id']

      organization_ids = sample.organization_ids.delete('[ ]').split(',')
      update_story(sample, story_pl_id, organization_ids)
    end

    def update_story(sample, story_pl_id, organization_ids)
      @pl_client.update_story(story_pl_id, organization_ids: organization_ids)
      sample.update("pl_#{@pl_client.environment}_id" => story_pl_id)
    end
  end
end
