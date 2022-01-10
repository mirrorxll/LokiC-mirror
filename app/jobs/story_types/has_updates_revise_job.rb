# frozen_string_literal: true

# Check if 'check_updates' method is developed?
module StoryTypes
  class HasUpdatesReviseJob < StoryTypesJob
    def perform
      StoryType.ongoing.with_developer.with_code.each do |story_type|
        sleep rand(5..10)
        code = story_type.code.download
        story_type.reminder.update(has_updates: nil) unless code.include?('def check_updates')
      end
    end
  end
end
