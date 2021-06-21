# frozen_string_literal: true

class RemindersJob < ApplicationJob
  queue_as :lokic

  def perform(story_types = StoryType.all)
    story_types.all.each do |st_type|
      next if st_type.cron_tab&.enabled || !st_type.code.attached? || st_type.remind_blocked?

      if st_type.updates?
        message(st_type, :has_updates)
        next
      end

      new_data_flag = MiniLokiC::Code[st_type].check_updates

      type =
        if !new_data_flag.in?([true, false])
          :method_missing
        elsif new_data_flag.eql?(true)
          st_type.update(updates: true)
          :has_updates
        elsif new_data_flag.eql?(false)
          next
        end

      message(st_type, type)
    end
  end

  private

  def message(story_type, type)
    url = Rails.application.routes.url_helpers.story_type_url(story_type)
    message = "<#{url}|Story type>"

    message +=
      case type
      when :method_missing
        '. Please develop check_updates method that should return true '\
        'if the source has new data or if not - false'
      when :has_updates
        ' has updates. Please check data and confirm data suitability'
      end

    send_to_dev_slack(story_type.iteration, :reminder, message)
  end
end
