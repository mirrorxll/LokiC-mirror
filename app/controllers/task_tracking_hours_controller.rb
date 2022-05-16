# frozen_string_literal: true

class TaskTrackingHoursController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  before_action :grid, only: :index

  def index
    @tab_title = "LokiC :: TaskTrackingHours"
    respond_to do |f|
      f.html do
        @grid.scope { |scope| scope.page(params[:page]).per(20) }
      end
    end
  end

  private

  def grid
    grid_params =
      if params[:task_tracking_hours_grid]
        params.require(:task_tracking_hours_grid).permit!
      else
        {}
      end
    @grid = TaskTrackingHoursGrid.new(grid_params)
  end
end
