# frozen_string_literal: true

module Api
  module V1
    class ScrapeTasksController < ApiController
      private

      def find_scrape_task
        @scrape_task = ScrapeTask.find(params[:scrape_task_id] || params[:id])
      end
    end
  end
end
