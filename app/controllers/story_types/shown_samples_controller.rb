# frozen_string_literal: true

class ShownSamplesController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration

  def index
    @grid_params =
      request.parameters[:shown_samples_grid] || {}

    @shown_samples_grid = StoryTypeShownSamplesGrid.new(@grid_params)
  end
end
