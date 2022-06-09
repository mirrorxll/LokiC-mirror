# frozen_string_literal: true

module ScrapeTasks
  class TagsController < ScrapeTasksController
    before_action :find_scrape_task
    before_action :find_or_create_tag_by_name, only: :include
    before_action :find_tag, only: :exclude

    def include
      render_403 && return if @scrape_task.tags.exists?(@tag.id)

      @scrape_task.tags << @tag
      render 'scrape_tasks/tags/refresh'
    end

    def exclude
      render_403 && return unless @scrape_task.tags.exists?(@tag.id)

      @scrape_task.tags.destroy(@tag)
      render 'scrape_tasks/tags/refresh'
    end

    private

    def find_scrape_task
      @scrape_task = ScrapeTask.find(params[:scrape_task_id])
    end

    def find_or_create_tag_by_name
      @tag = ScrapeTaskTag.find_or_create_by!(name: tag_name_from_param)
    end

    def find_tag
      @tag = ScrapeTaskTag.find(params[:tag_id])
    end

    def tag_name_from_param
      params.require(:tag).permit(:name)[:name]
    end
  end
end
