# frozen_string_literal: true

class ReminderUpdatesJob < ApplicationJob
  queue_as :lokic

  def perform(story_types = StoryType.all)
    story_types.all.each do |st_type|
      st_type.reminder || st_type.create_reminder

      next if st_type.developer.nil?
      next if st_type.cron_tab&.enabled || !st_type.code.attached? || st_type.reminder_off?

      if st_type.updates_confirmed?
        message(st_type, :updates_confirmed)
        next
      elsif st_type.updates?
        message(st_type, :has_updates)
        next
      end

      new_data_flag = MiniLokiC::Code[st_type].check_updates

      type =
        if !new_data_flag.in?([true, false])
          :method_missing
        elsif new_data_flag.eql?(true)
          st_type.reminder.update_column(:has_updates, true)
          :has_updates
        elsif new_data_flag.eql?(false)
          next
        end

      message(st_type, type)
    end
  end

  private

  def message(story_type, type)
    message =
      case type
      when :method_missing
        'Please develop *check_updates* method. It should return true '\
        'if the source has new data or if not - false'
      when :has_updates
        'Story Type has updates! Please check source data set and confirm this'
      when :updates_confirmed
        "Story Type has updates! Let's make stories :)"
      end

    send_to_dev_slack(story_type.iteration, 'REMINDER', message)
    story_type.reminder.alerts.create(message: message)
  end
end
