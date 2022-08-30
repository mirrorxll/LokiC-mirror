# frozen_string_literal: true

module MultiTasks
  class TrackingHoursController < MultiTasksController
    before_action :grid, only: :index

    def index
      @tab_title = 'LokiC :: TaskTrackingHours'
      respond_to do |f|
        f.html do
          @grid.scope { |scope| scope.page(params[:page]).per(30) }
        end
      end
    end

    private

    def grid
      grid_params =
        if params[:multi_task_tracking_hours_grid]
          params.require(:multi_task_tracking_hours_grid).permit!
        else
          {}
        end
      @grid = TaskTrackingHoursGrid.new(grid_params)
    end
  end
end
