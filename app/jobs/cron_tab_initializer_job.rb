class CronTabInitializerJob < ApplicationJob
  queue_as :cron_tab

  def perform
    CronTab.all.each do |tab|
      next unless tab.enabled

      Sidekiq.set_schedule(
        "story_type_#{tab.story_type.id}",
        { cron: tab.pattern, class: 'CronTabExecuteJob', args: [tab.story_type.id] }
      )
    end
  end
end
