# frozen_string_literal: true

class CronTab < ApplicationRecord
  serialize :setup, HashWithIndifferentAccess

  before_update do
    if enabled_changed?
      event, message =
        if enabled
          ['installed on cron', pattern]
        else
          ['cron turned off', '---']
        end

      record_to_change_history(story_type, event, message, current_account)
    end
  end

  validate :check_pattern, on: :update

  belongs_to :story_type

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
