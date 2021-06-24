# frozen_string_literal: true

class CronTab < ApplicationRecord
  serialize :setup, Hash

  after_save do
    name, notes =
      if enabled && !freeze_execution
        ['installed on cron', "installed on cron with pattern #{pattern}"]
      else
        ['cron turned off', 'cron execution disabled']
      end

    event = HistoryEvent.find_by(name: name)
    story_type.change_history.create(history_event: event, notes: notes)
  end

  validate :check_pattern

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
