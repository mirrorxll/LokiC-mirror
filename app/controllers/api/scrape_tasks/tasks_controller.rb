# frozen_string_literal: true

module Api
  module ScrapeTasks
    class TasksController < ApiController
      before_action :find_scrape_task
      before_action :find_task

      def create
        json =
          if @scrape_task.multi_tasks.exists?(@task.id)
            { exist: true }
          else
            @scrape_task.multi_tasks << @task
            { exist: false, task_id: @task.id, task_name: @task.title }
          end

        render json: json
      end

      def destroy
        not_exist =
          if @scrape_task.multi_tasks.exists?(@task.id)
            @scrape_task.multi_tasks.destroy(@task)
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
        @task =
          if params[:multi_task_title]
            Task.find_by(title: params[:multi_task_title])
          else
            Task.find(params[:id])
          end
      end
    end
  end
end
