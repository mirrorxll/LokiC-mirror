# frozen_string_literal: true

class CronTab < ApplicationRecord
  serialize :setup, Hash

  before_update do
    if enabled_changed?
      event, message =
        if enabled
          ['installed on cron', "installed on cron with #{pattern}"]
        else
          ['cron turned off', 'cron execution disabled']
        end

      record_to_change_history(story_type, event, message, current_account)
    end
  end

  validate :check_pattern, on: :update

  belongs_to :story_type
  belongs_to :adjuster, class_name: 'Account'

  def pattern
    cron = setup[:pattern]
    "#{cron[:minute]} #{cron[:hour]} #{cron[:month_day]} #{cron[:month]} #{cron[:week_day]}"
  end

  def population_params
    setup[:population_params]
  end

  private

  def check_pattern
    Rufus::Scheduler.parse(pattern)
  rescue ArgumentError => e
    errors.add(pattern, e.message)
  end
end
