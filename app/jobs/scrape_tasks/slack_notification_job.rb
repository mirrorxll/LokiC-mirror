# frozen_string_literal: true

module ScrapeTasks
  class SlackNotificationJob < ScrapeTasksJob
    def perform(task, step, raw_message, scraper = nil)
      task_scraper = scraper || task.scraper

      url = generate_url(task)
      progress_step = step.eql?('scraper') ? '' : "| #{step.capitalize}"
      scraper_name = task_scraper.name
      message = "*<#{url}|Scrape Task ##{task.id}> #{progress_step} | #{scraper_name}*\n#{raw_message}".gsub("\n", "\n>")

      record_to_alerts(task, step, raw_message)

      ::SlackNotificationJob.perform_now('lokic_scrape_task_messages', message)
      return if task.scraper_slack_id.nil?

      message = message.gsub(/#{Regexp.escape(" | #{scraper_name}")}/, '')
      ::SlackNotificationJob.perform_now(task.scraper_slack_id, "*[ LokiC ]* #{message}")
    end
  end
end
