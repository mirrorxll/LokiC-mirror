# frozen_string_literal: true

module ScrapeTasks
  class SlackNotificationJob < ScrapeTasksJob
    def perform(scrape_task_id, step, raw_message, scraper_id = nil)
      scrape_task = ScrapeTask.find(scrape_task_id)
      task_scraper = Account.find_by(id: scraper_id) || scrape_task.scraper

      url = generate_url(scrape_task)
      progress_step = step.eql?('scraper') ? '' : "| #{step.capitalize}"
      scraper_name = task_scraper.name
      message = "*<#{url}|Scrape Task ##{scrape_task.id}> #{progress_step} | #{scraper_name}*\n#{raw_message}".gsub("\n", "\n>")

      record_to_alerts(scrape_task, step, raw_message)

      ::SlackNotificationJob.new.perform('lokic_scrape_task_messages', message)
      return if scrape_task.scraper_slack_id.nil?

      message = message.gsub(/#{Regexp.escape(" | #{scraper_name}")}/, '')
      ::SlackNotificationJob.new.perform(scrape_task.scraper_slack_id, "*[ LokiC ]* #{message}")
    end
  end
end
