# frozen_string_literal: true

class ProductionRemovalsController < ApplicationController
  skip_before_action :set_iteration
  skip_before_action :find_parent_story_type

  def index
    @grid_params = request.parameters[:exported_story_types_grid] || {}
    @removals_grid = ProductionRemovalsGrid.new(@grid_params)
    @removals_grid.scope { |scope| scope.page(params[:page]).per(50) }
  end
end
