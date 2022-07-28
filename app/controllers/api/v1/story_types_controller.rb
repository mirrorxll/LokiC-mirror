# frozen_string_literal: true

module Api
  module V1
    class StoryTypesController < ApiController
      private

      def find_story_type
        @story_type = StoryType.find(params[:story_type_id] || params[:id])
      end
    end
  end
end
