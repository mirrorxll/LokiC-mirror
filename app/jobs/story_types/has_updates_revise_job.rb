# frozen_string_literal: true

# Check if 'check_updates' method is developed?
module StoryTypes
  class HasUpdatesReviseJob < StoryTypesJob
    def perform(*_args)
      StoryType.ongoing.with_developer.with_code.not_cron.each do |story_type|
        code = story_type.code.download
        story_type.reminder.update(check_updates: true) if code.match?(/def\s+check_updates/)
      end
    end
  end
end
