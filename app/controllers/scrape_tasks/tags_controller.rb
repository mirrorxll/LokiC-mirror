# frozen_string_literal: true

module ScrapeTasks
  class TagsController < ScrapeTasksController
    before_action :find_scrape_task

    def show; end

    def edit; end

    def update
      @scrape_task.tags.clear

      tags_params.keep_if { |_k, v| v.eql?('1') }.keys.each do |tag|
        @scrape_task.tags << ScrapeTaskTag.find_or_create_by!(name: tag)
      end

      render 'scrape_tasks/tags/show'
    end

    private

    def tags_params
      params[:tags] ? params.require(:tags).permit!.to_h : {}
    end
  end
end
