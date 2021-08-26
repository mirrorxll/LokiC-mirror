# frozen_string_literal: true

class ScrapeInstructionsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  before_action :find_scrape_task

  def edit; end

  def cancel_edit; end

  def update
    @scrape_task.scrape_instruction.update!(instruction_params)
  end

  private

  def find_scrape_task
    @scrape_task = ScrapeTask.find(params[:scrape_task_id])
  end

  def instruction_params
    params.require(:scrape_instruction).permit(:body)
  end
end
