# frozen_string_literal: true

module ScrapeTasks
  class ScrapersController < ScrapeTasksController
    before_action :find_scrape_task
    before_action :find_scraper, only: :update

    def show; end

    def edit
      @scrapers = AccountRole.find_by(name: 'Scrape Developer').accounts
    end

    def update
      if @scraper.nil? || @scraper.roles.find_by(name: 'Scrape Developer')
        @scrape_task.update(scraper: @scraper)
      else
        flash.now[:error] = { scraper: :error }
      end

      render 'scrape_tasks/scrapers/show'
    end

    private

    def find_scraper
      @scraper = Account.find_by(id: params[:scraper][:id])
    end
  end
end
