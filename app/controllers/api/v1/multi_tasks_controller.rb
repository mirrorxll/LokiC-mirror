# frozen_string_literal: true

module Api
  module V1
    class MultiTasksController < ApiController
      private

      def find_multi_task
        @multi_task = ScrapeTask.find(params[:multi_task_id] || params[:id])
      end
    end
  end
end
