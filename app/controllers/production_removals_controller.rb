# frozen_string_literal: true

class ProductionRemovalsController < ApplicationController
  def index
    @tab_title = "LokiC :: ProductionRemovals"
    @grid = request.parameters[:exported_story_types_grid] || {}
    @removals_grid = StoryTypeProductionRemovalsGrid.new(@grid)
    @removals_grid.scope { |scope| scope.page(params[:page]).per(30) }
  end
end
