# frozen_string_literal: true

class ScrapeTaskStatusesController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration

  before_action :find_scrape_task
  before_action :find_status

  def change
    @scrape_task.update(status: @status)
    @scrape_task.status_comment.update(body: params[:reasons]) if params[:reasons]
  end

  private

  def find_scrape_task
    @scrape_task = ScrapeTask.find(params[:scrape_task_id])
  end

  def find_status
    @status = Status.find(params[:status_id])
  end
end
