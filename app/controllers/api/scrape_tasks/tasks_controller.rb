# frozen_string_literal: true

module Api
  module ScrapeTasks
    class TasksController < ApiController
      before_action :find_scrape_task
      before_action :find_task

      def include
        json =
          if @scrape_task.multi_tasks.exists?(@task.id)
            { not_included: true }
          else
            @scrape_task.multi_tasks << @task
            { task_id: @task.id, task_name: @task.title }
          end

        render json: json
      end

      def exclude
        excluded =
          if @scrape_task.multi_tasks.exists?(@task.id)
            @scrape_task.multi_tasks.destroy(@task)
            false
          else
            true
          end

        render json: { not_excluded: excluded }
      end

      private

      def find_scrape_task
        @scrape_task = ScrapeTask.find(params[:scrape_task_id])
      end

      def find_task
        @task = Task.find(params[:task_id])
      end
    end
  end
end
