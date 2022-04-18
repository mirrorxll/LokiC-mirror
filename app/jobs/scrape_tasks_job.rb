# frozen_string_literal: true

class ScrapeTasksJob < ApplicationJob
  sidekiq_options queue: :scrape_task
end
