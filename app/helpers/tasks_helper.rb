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
end
