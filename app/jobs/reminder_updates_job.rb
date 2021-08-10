# frozen_string_literal: true

class ReminderUpdatesJob < ApplicationJob
  queue_as :lokic

  def perform(story_types = StoryType.all)
    Process.wait(
      fork do
        story_types.each do |st_type|
          sleep(rand)

          next if st_type.developer.nil?
          next if st_type.status.name.in?(['canceled', 'migrated', 'not started', 'blocked', 'done'])
          next if st_type.cron_tab&.enabled || !st_type.code.attached? || st_type.reminder_off?

          type =
            if st_type.updates_confirmed?
              :updates_confirmed
            elsif st_type.updates?
              :has_updates
            end

          if type
            send_message(st_type, type)
            next
          end

          begin
            new_data_flag = MiniLokiC::Code[st_type].check_updates
          rescue StandardError, ScriptError => e
            msg = "[ CheckUpdatesExecutionError ] -> #{e.message} at #{e.backtrace.first}".gsub('`', "'")
            SlackReminderNotificationJob.perform_now(st_type.iteration, 'reminder', msg)
            next
          end

          type =
            if !new_data_flag.in?([true, false])
              :method_missing
            elsif new_data_flag.eql?(true)
              st_type.reminder.update!(has_updates: true, current_account: st_type.developer)
              :has_updates
            elsif new_data_flag.eql?(false)
              next
            end

          send_message(st_type, type)
        end
      end
    )
  end

  private

  def send_message(story_type, type)
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

    SlackReminderNotificationJob.perform_now(story_type, message)
  end
end
