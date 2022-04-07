# frozen_string_literal: true

class CronTabInitializerJob < ApplicationJob
  queue_as :cron_tab

  def perform
    CronTab.all.each do |tab|
      next unless tab.enabled

      Sidekiq.set_schedule(
        "story_type_#{tab.story_type.id}",
        { cron: tab.pattern, class: 'StoryTypes::CronTabJob', args: [tab.story_type.id], queue: 'cron_tab' }
      )
    end
  end
end
