# frozen_string_literal: true

module Api
  module MultiTasks
    class StatusesController < ApiController
      before_action :find_task
      before_action :find_status

      def index
        render json: Status.multi_task_statuses.map(&:name)
      end

      def update
        render json: { success: @multi_task.update(status: @status) }
      end

      private

      def find_task
        @multi_task = MultiTask.find(params[:multi_task_id])
      end

      def find_status
        @status = Status.find(params[:id])
      end
    end
  end
end
