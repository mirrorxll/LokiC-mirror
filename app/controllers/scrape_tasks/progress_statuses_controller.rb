# frozen_string_literal: true

module ScrapeTasks
  class ProgressStatusesController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :find_parent_article_type
    skip_before_action :set_story_type_iteration
    skip_before_action :set_article_type_iteration

    before_action :find_scrape_task
    before_action :find_status

    def change
      @scrape_task.status_comment.update!(body: params[:reasons]) if params[:reasons]
      @scrape_task.update!(status: @status, current_account: current_account)
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
