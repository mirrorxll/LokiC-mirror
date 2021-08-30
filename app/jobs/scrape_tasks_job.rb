# frozen_string_literal: true

class ScrapeTasksJob < ApplicationJob
  queue_as :scrape_task
end
