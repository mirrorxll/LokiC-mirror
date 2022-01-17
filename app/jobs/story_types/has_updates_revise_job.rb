# frozen_string_literal: true

# Check if 'check_updates' method is developed?
module StoryTypes
  class HasUpdatesReviseJob < StoryTypesJob
    def perform
      StoryType.ongoing.with_developer.with_code.not_cron.each do |story_type|
        sleep 1
        code = story_type.code.download
        story_type.reminder.update(has_updates: nil) unless code.match?(/def\s+check_updates/)
      end
    end
  end
end
