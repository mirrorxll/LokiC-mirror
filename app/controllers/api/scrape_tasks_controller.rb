# frozen_string_literal: true

module Api
  class ScrapeTasksController < Api::ApiController
    def names
      sc_task_names = ScrapeTask.all.map(&:name)

      render json: sc_task_names
    end

    def data_set_locations
      value = data_set_location_params[:value].gsub('%', '')

      sc_tasks_dt_locations =
        ScrapeTask.where(
          "data_set_location RLIKE '#{value}'"
        ).select(:id, :name).limit(11)

      render json: sc_tasks_dt_locations
    end

    private

    def data_set_location_params
      params.require(:scrape_task).permit(:value)
    end
  end
end
