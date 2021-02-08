class CronTabSetupJob < ApplicationJob
  queue_as :cron_tab

  def perform(story_type)
    cron_tab = story_type.cron_tab
    cron_tab_name = "story_type_#{story_type.id}"
    config = { cron: cron_tab.pattern, class: 'CronTabExecuteJob', args: [story_type.id] }

    if cron_tab.enabled
      Sidekiq.set_schedule(cron_tab_name, config)
    else
      Sidekiq.remove_schedule(cron_tab_name)
    end
  end
end
