# frozen_string_literal: true

module ScrapeTasks
  class ProgressStatusesController < ScrapeTasksController
    before_action :find_scrape_task
    before_action :find_status

    def update
      @scrape_task.status_comment.update!(body: params[:reasons]) if params[:reasons]
      @scrape_task.update!(status: @status, current_account: @current_account)
    end

    private

    def find_scrape_task
      @scrape_task = ScrapeTask.find(params[:scrape_task_id])
    end

    def find_status
      @status = Status.find(params[:status_id])
    end
  end
end
