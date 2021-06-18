# frozen_string_literal: true

class RemindersJob < ApplicationJob
  queue_as :lokic

  def perform
    StoryType.all.each do |story_type|
      next if story_type.cron_tab

      recent_data_timestamp = MiniLokiC::Code[story_type].check_updates
    end
  end
end
