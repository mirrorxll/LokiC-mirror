# frozen_string_literal: true

class ScrapeTasksController < ApplicationController
  before_action -> { authorize!('scrape_tasks') }

  private

  def find_scrape_task
    @scrape_task = ScrapeTask.find( params[:scrape_task_id] || params[:id])
  end
end
