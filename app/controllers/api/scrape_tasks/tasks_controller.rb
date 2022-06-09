# frozen_string_literal: true

module Api
  module ScrapeTasks
    class TasksController < ApiController
      before_action :find_scrape_task
      before_action :find_task

      def create
        json =
          if @scrape_task.tasks.exists?(@multi_task.id)
            { already_attach: true }
          else
            @scrape_task.tasks << @multi_task
            { already_attached: false, id: @multi_task.id, name: @multi_task.title, subtask: @multi_task.subtask? }
          end

        render json: json
      end

      def destroy
        not_exist =
          if @scrape_task.tasks.exists?(@multi_task.id)
            @scrape_task.tasks.destroy(@multi_task)
            false
          else
            true
          end

        render json: { not_exist: not_exist }
      end

      private

      def find_scrape_task
        @scrape_task = ScrapeTask.find(params[:scrape_task_id])
      end

      def find_task
        @multi_task =
          if params[:task_title]
            Task.find_by(title: params[:task_title])
          else
            Task.find(params[:id])
          end
      end
    end
  end
end
