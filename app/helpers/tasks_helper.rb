# frozen_string_literal: true

module TasksHelper
  def collapse(tasks_grid)
    if tasks_grid.nil?
      'collapse'
    elsif !tasks_grid.nil? && tasks_grid[:collapse]
      'collapse'
    else
      ''
    end
  end

  def sorted_reminder_frequencies
    TaskReminderFrequency.all.sort_by do |frequency|
      case frequency.name
      when 'each Monday' then 2
      when 'each Tuesday' then 3
      when 'each Wednesday' then 4
      when 'each Thursday' then 5
      when 'each Friday' then 6
      when 'each Saturday' then 7
      when 'each Sunday' then 8
      else 1
      end
    end
  end

  def parent_title(title)
    title.length > 40 ? title.first(40) + '...' : title
  end
end
