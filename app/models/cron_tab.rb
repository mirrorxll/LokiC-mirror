# frozen_string_literal: true

class CronTab < ApplicationRecord
  serialize :setup, Hash

  belongs_to :story_type

  def pattern
    cron = setup[:pattern]
    "#{cron[:minute]} #{cron[:hour]} #{cron[:month_day]} #{cron[:month]} #{cron[:week_day]}"
  end

  def population_params
    setup[:population_params]
  end
end
