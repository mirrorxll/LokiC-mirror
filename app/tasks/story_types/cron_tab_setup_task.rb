# frozen_string_literal: true

module StoryTypes
  class CronTabSetupTask < ApplicationTask
    def perform(story_type_id)
      story_type = StoryType.find(story_type_id)
      crontab_setup = `bundle exec whenever --write-crontab --set environment=#{Rails.env}`

      message =
        case crontab_setup
        when ''
          story_type.cron_tab.update!(enabled: false)
          'Crontab not set. Check your pattern and set it again or contact with manager'
        else
          if story_type.cron_tab.enabled
            "Crontab set -> `#{story_type.cron_tab.pattern}`"
          else
            'Crontab disabled'
          end
        end

      SlackCronTabSetupNotificationTask.new.perform(story_type_id, message)
    end
  end
end
