# frozen_string_literal: true

class ReminderProgressJob < ApplicationJob
  queue_as :lokic

  def perform(story_types = StoryType.all)
    story_types.all.each do |st_type|
      distributed_gap = (Date.today - st_type.distributed_at.to_date).to_i
      last_status_change_gap = (Date.today - st_type.last_status_changed_at.to_date).to_i
      inactive = false

      # not migrated story type not started more than seven days
      if distributed_gap > 7 && !st_type.migrated && st_type.status.name.in?(['in progress', 'inactive'])
        message(st_type, :story_type_not_started)
        inactive = true
      end

      # status not changed during two weeks or more
      if last_status_change_gap > 14 && st_type.status.name.in?(['in progress', 'inactive'])
        message(st_type, :story_type_not_exported)
        inactive = true
      end

      next unless inactive

      st_type.update(status: Status.find_by(name: 'inactive'))
      notes = "progress status changed to 'inactive'"
      record_to_change_history(st_type, 'progress status changed', notes)
    end
  end

  private

  def message(story_type, type)
    last_sentence = '. If you have some problems with this Story Type or this alert is false '\
                    "please contact with data's sheriff or manager"

    message =
      case type
      when :story_type_not_started
        "Story Type hasn't started yet#{last_sentence}"
      when :story_type_not_exported
        "Story Type has status 'in progress' more than two weeks and still not exported#{last_sentence}"
      end

    send_to_dev_slack(story_type.iteration, 'REMINDER', message)
    story_type.reminder.alerts.create(message: message)
  end
end
