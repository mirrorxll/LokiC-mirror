# frozen_string_literal: true

module ProgressStatusesHelper
  def status_color(name)
    case name
    when 'migrated', 'not started'
      'secondary text-white'
    when 'in progress'
      'primary text-white'
    when 'exported', 'done'
      'dark text-white'
    when 'on cron'
      'warning'
    when 'blocked'
      'danger text-white'
    else
      ''
    end
  end

  def flash_color(message)
    message.start_with?('Success') ? 'success' : 'danger'
  end
end
