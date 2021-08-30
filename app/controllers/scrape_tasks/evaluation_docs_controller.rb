# frozen_string_literal: true

module ScrapeTasks
  class EvaluationDocsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: :autosave

    skip_before_action :find_parent_story_type
    skip_before_action :find_parent_article_type
    skip_before_action :set_story_type_iteration
    skip_before_action :set_article_type_iteration

    before_action :find_scrape_task
    before_action :update_eval_doc, only: %i[update autosave]

    def edit; end

    def cancel_edit; end

    def update; end

    def autosave
      render status: :ok
    end

    private

    def find_scrape_task
      @scrape_task = ScrapeTask.find(params[:scrape_task_id])
    end

    def evaluation_doc_params
      params.require(:evaluation_doc).permit(:body)
    end

    def update_eval_doc
      @scrape_task.scrape_evaluation_doc.update!(evaluation_doc_params)
    end
  end
end
