# frozen_string_literal: true

module StoryTypes
  class ShownSamplesController < StoryTypesController
    skip_before_action :find_parent_story_type
    skip_before_action :find_parent_article_type
    skip_before_action :set_story_type_iteration
    skip_before_action :set_article_type_iteration

    def index
      @grid =
        request.parameters[:shown_samples_grid] || {}

      @shown_samples_grid = StoryTypeShownSamplesGrid.new(@grid)
    end
  end
end
