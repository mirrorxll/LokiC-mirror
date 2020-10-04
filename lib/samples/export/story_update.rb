# frozen_string_literal: true

module Samples
  module Export
    module StoryUpdate
      private

      def story_update(story_id, organization_ids, pl_r_client)
        response = @pl_client.update_story(story_id, organization_ids: organization_ids)
        return if (response.status / 100).eql?(2)

      end
    end
  end
end
