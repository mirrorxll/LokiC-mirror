# frozen_string_literal: true

class ShownSamplesController < ApplicationController
  skip_before_action :set_iteration
  skip_before_action :find_parent_story_type

  def index
    @grid_params =
      request.parameters[:shown_samples_grid] || { order: :id }

    @shown_samples_grid = ShownSamplesGrid.new(@grid_params)
    @shown_samples_grid.scope { |scope| scope.page(params[:page]).per(50) }
  end
end
