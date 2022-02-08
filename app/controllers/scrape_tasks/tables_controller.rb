# frozen_string_literal: true

module ScrapeTasks
  class TablesController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :find_parent_article_type
    skip_before_action :set_story_type_iteration
    skip_before_action :set_article_type_iteration

    before_action :find_scrape_task

    def new; end

    def create
    end

    def destroy

    end

    private

    def find_scrape_task
      @scrape_task = ScrapeTask.find(params[:scrape_task_id])
    end
  end
end
