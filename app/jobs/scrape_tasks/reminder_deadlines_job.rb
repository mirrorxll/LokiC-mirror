# frozen_string_literal: true

module ScrapeTasks
  class ReminderDeadlinesJob < ScrapeTasksJob
    def perform(scrape_tasks = ScrapeTask.where.not(deadline: nil))
      scrape_tasks.each do |st|

      end
    end
  end
end
