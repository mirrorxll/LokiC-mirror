# frozen_string_literal: true

module ScrapeTasks
  class GitLinksController < ScrapeTasksController
    before_action :find_scrape_task

    def show; end

    def edit; end

    def update
      ScrapeTaskGitLink.find_or_create_by(scrape_task_id: @scrape_task.id).update(git_params)
      @git_link = ScrapeTaskGitLink.find_or_create_by(scrape_task_id: @scrape_task.id)
      @git_link.update(git_params)

      flash.now[:error] = @git_link.errors if @git_link.errors.messages.any?
      render 'scrape_tasks/git_links/show'
    end

    private

    def git_params
       params.require(:git_link).permit(:link)
    end
  end
end
