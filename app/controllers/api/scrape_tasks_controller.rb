# frozen_string_literal: true

module Api
  class ScrapeTasksController < ApiController
    def names
      sc_task_names = ScrapeTask.all.map(&:name)

      render json: sc_task_names
    end
  end
end
