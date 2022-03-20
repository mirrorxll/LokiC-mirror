# frozen_string_literal: true

module Api
  class StoryTypesController < ApiController
    before_action :find_story_type

    private

    def find_story_type
      @story_type = StoryType.find(params[:story_type_id])
    end
  end
end
