class CronTabInitializerJob < ApplicationJob
  queue_as :default

  def perform
    Sidekiq.set_schedule(:clients_publications_tags, cron: '0 0 * * *', class: ClientsPublicationsTagsJob)
    Sidekiq.set_schedule(:clients_tags, cron: '10 0 * * *', class: ClientsTagsJob)
    Sidekiq.set_schedule(:sections, cron: '20 0 * * *', class: SectionsJob)
    Sidekiq.set_schedule(:photo_buckets, cron: '30 0 * * *', class: PhotoBucketsJob)
    Sidekiq.set_schedule(:slack_accounts, cron: '40 0 * * *', class: SlackAccountsJob)

    CronTab.all.each do |tab|
      next unless tab.enabled

      Sidekiq.set_schedule(
        "story_type_#{tab.story_type.id}",
        { cron: tab.pattern, class: 'CronTabExecuteJob', args: [tab.story_type.id] }
      )
    end
  end
end
