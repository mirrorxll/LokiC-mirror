# frozen_string_literal: true

module Pipeline
  module MainEndpoint
    # Story endpoints
    module Story
      # https://pipeline-api-docs.locallabs.com/#get-a-story
      def get_story(id)
        get("stories/#{id}")
      end

      # https://pipeline-api-docs.locallabs.com/#create-a-story
      def post_story(body = {})
        post('stories', body)
      end

      # https://pipeline-api-docs.locallabs.com/#update-a-story
      def update_story(id, body = {})
        put("stories/#{id}", body)
      end

      # https://pipeline-api-docs.locallabs.com/#delete-a-story
      def delete_story(id)
        delete("stories/#{id}")
      end
    end
  end
end
