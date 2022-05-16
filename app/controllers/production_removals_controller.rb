# frozen_string_literal: true

class ProductionRemovalsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  def index
    @tab_title = "LokiC :: ProductionRemovals"
    @grid_params = request.parameters[:exported_story_types_grid] || {}
    @removals_grid = StoryTypeProductionRemovalsGrid.new(@grid_params)
    @removals_grid.scope { |scope| scope.page(params[:page]).per(50) }
  end
end
