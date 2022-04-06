# frozen_string_literal: true

class CronTabInitializerJob < ApplicationJob
  queue_as :cron_tab

  def perform
    Sidekiq.set_schedule(:clients_publications_tags, class: ClientsPublicationsTagsJob, cron: '0 0 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:clients_tags,              class: ClientsTagsJob, cron: '30 0 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:sections,                  class: SectionsJob, cron: '0 1 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:photo_buckets,             class: PhotoBucketsJob, cron: '30 1 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:opportunities,             class: OpportunitiesJob, cron: '0 2 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:clients_opportunities,     class: ClientsOpportunitiesJob, cron: '30 2 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:slack_accounts,            class: SlackAccountsJob, cron: '40 0 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:reminder_updates,          class: StoryTypes::ReminderUpdatesJob, cron: '0 5 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:reminder_progress,         class: StoryTypes::ReminderProgressJob, cron: '0 6 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:reminder_tasks,            class: ReminderTasksJob, cron: '0 7 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:tasks_confirms_receipts,   class: TasksConfirmsReceiptsJob, cron: '0 14 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:tasks_confirms_receipts_2, class: TasksConfirmsReceiptsJob, cron: '0 17 * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:has_updates_revise,        class: StoryTypes::HasUpdatesReviseJob, cron: '0 * * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:schemes_tables,            class: ScrapeTasks::SchemesTablesJob, cron: '0 * * * *', queue: 'cron_tab')
    Sidekiq.set_schedule(:revision_reminder,         class: StoryTypes::RevisionReminderJob, cron: '0 8 * * *', queue: 'cron_tab')

    CronTab.all.each do |tab|
      next unless tab.enabled

      Sidekiq.set_schedule(
        "story_type_#{tab.story_type.id}",
        { cron: tab.pattern, class: 'StoryTypes::CronTabJob', args: [tab.story_type.id], queue: 'cron_tab' }
      )
    end
  end
end
