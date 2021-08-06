# frozen_string_literal: true

class SlackScrapeTaskNotificationJob < ApplicationJob
  queue_as :scrape_task

  def perform(task, step, raw_message)
    channel = Rails.env.production? ? 'lokic_scrape_task_messages' : 'hle_lokic_development_messages'
    url = generate_url(task)
    message = "*<#{url}|Scrape Task ##{task.id}>*\n#{raw_message}".gsub("\n", "\n>")

    SlackNotificationJob.perform_now(channel, message)
    return if task.scraper_slack_id.nil?

    SlackNotificationJob.perform_now(task.scraper_slack_id, "*[ LokiC ]* #{message}")
    record_to_alerts(task, step, raw_message)
  end
end
