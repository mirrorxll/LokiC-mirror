class StoryTypes::HasUpdatesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    StoryType.all.each do |story_type|
      code = story_type.code.download
      story_type.reminder.update(has_updates: nil) unless code.include?('def check_updates')
    end
  end
end
