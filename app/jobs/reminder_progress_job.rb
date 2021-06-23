# frozen_string_literal: true

class ReminderProgressJob < ApplicationJob
  queue_as :lokic

  def perform(story_types = StoryType.all)
    story_types.all.each do |st_type|
      distributed_gap = (DateTime.now - st_type.distributed_at).to_i
      last_status_change_gap = (DateTime.now - st_type.last_status_changed_at).to_i

      if distributed_gap > 7 && st_type.status.name.eql?('not started') && st_type.last_status_changed_at.nil?
        message(st_type, :story_type_not_started)
      end

      if distributed_gap > 14 && st_type.iterations.count.eql?(1) && st_type.status.eql?('in progress')
        message(st_type, :status_not_change)
      end

      if last_status_change_gap > 14 && st_type.status.eql?('in progress')
        message(st_type, :inactive)
      end
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
  end
end
