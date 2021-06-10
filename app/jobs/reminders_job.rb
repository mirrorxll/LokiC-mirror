# frozen_string_literal: true

class RemindersJob < ApplicationJob
  queue_as :default

  def perform
    StoryType.all.each do |story_type|
      next if story_type.cron_tab

      MiniLokiC::Code.execute(story_type, :check_updates)
    end
  end
end
