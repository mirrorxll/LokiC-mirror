class SetupCronTabJob < ApplicationJob
  queue_as :default

  def perform(story_type)
    cron_tab = story_type.cron_tab
    cron_tab_name = "story_type_#{story_type.id}"

    if cron_tab.enabled
      Sidekiq.set_schedule(
        cron_tab_name,
        { cron: cron_tab.pattern, class: 'ExecuteCronTabJob', args: [story_type.id] }
      )
    else
      Sidekiq.remove_schedule(cron_tab_name)
    end
  end
end
