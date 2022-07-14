# frozen_string_literal: true

module ProgressStatusesHelper
  def status_color(name)
    case name.strip.downcase
    when /migrated|created and in queue|deactivated/
      'secondary text-white'
    when /in progress|active/
      'primary text-white'
    when /exported|done|deleted/
      'dark text-white'
    when /on cron/
      'warning'
    when /blocked/
      'danger text-white'
    else
      ''
    end
  end

  def flash_color(message)
    message.start_with?('Success') ? 'success' : 'danger'
  end
end
