# frozen_string_literal: true

module ScrapeTasks
  class MultiTasksController < ScrapeTasksController
    before_action :find_scrape_task
  end
end
