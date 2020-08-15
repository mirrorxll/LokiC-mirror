# frozen_string_literal: true

module SchedulesHelper
  def schedules_alert(message)
    messages = [
      'manual scheduling success',
      'backdate scheduling success',
      'auto scheduling success'
    ]

    messages.include?(message) ? 'success' : 'danger'
  end
end
