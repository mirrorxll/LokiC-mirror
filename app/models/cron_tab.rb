# frozen_string_literal: true

class CronTab < ApplicationRecord
  serialize :setup, Hash

  belongs_to :story_type

  validate :check_pattern

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
