# frozen_string_literal: true

module ScrapeTasks
  class InstructionsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: :autosave

    skip_before_action :find_parent_story_type
    skip_before_action :find_parent_article_type
    skip_before_action :set_story_type_iteration
    skip_before_action :set_article_type_iteration

    before_action :find_scrape_task
    before_action :update_instruction, only: %i[update autosave]

    def edit; end

    def cancel_edit; end

    def update; end

    def autosave
      head :ok
    end

    private

    def find_scrape_task
      @scrape_task = ScrapeTask.find(params[:scrape_task_id])
    end

    def instruction_params
      params.require(:instruction).permit(:body)
    end

    def update_instruction
      @scrape_task.scrape_instruction.update!(instruction_params)
    end
  end
end
