# frozen_string_literal: true

class ScrapeEvaluationDocsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration

  before_action :find_scrape_task

  def edit; end

  def cancel_edit; end

  def update
    @scrape_task.scrape_evaluation_doc.update(evaluation_doc_params)
  end

  private

  def find_scrape_task
    @scrape_task = ScrapeTask.find(params[:scrape_task_id])
  end

  def evaluation_doc_params
    params.require(:evaluation_doc).permit(:body)
  end
end
