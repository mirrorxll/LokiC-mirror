# frozen_string_literal: true

class CronTabInitializerJob < ApplicationJob
  queue_as :cron_tab

  def perform
    Sidekiq.set_schedule(:clients_publications_tags, class: ClientsPublicationsTagsJob, cron: '0 0 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:clients_tags, class: ClientsTagsJob, cron: '10 0 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:sections, class: SectionsJob, cron: '20 0 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:photo_buckets, class: PhotoBucketsJob, cron: '30 0 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:slack_accounts, class: SlackAccountsJob, cron: '40 0 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:reminder_updates, class: ReminderUpdatesJob, cron: '0 5 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:reminder_progress, class: ReminderProgressJob, cron: '0 6 * * *', queue: 'cron_tab')

    CronTab.all.each do |tab|
      next unless tab.enabled

      Sidekiq.set_schedule(
        "story_type_#{tab.story_type.id}",
        { cron: tab.pattern, class: 'CronTabExecuteJob', args: [tab.story_type.id], queue: 'cron_tab' }
      )
    end
  end
end
