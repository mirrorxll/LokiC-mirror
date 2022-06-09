# frozen_string_literal: true

class ScrapeTasksController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  private

  def find_scrape_task
    @scrape_task = ScrapeTask.find( params[:scrape_task_id] || params[:id])
  end
end
