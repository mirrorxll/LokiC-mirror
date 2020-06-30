# frozen_string_literal: true

module IterationsHelper
  def iteration_color(story_type, iteration)
    case iteration.statuses.first.name
    when 'not started'
      'secondary'
    when 'in progress'
      'primary'
    when 'exported'
      'dark'
    when 'on cron'
      'warning'
    when 'blocked'
      'danger'
    end
  end
end
