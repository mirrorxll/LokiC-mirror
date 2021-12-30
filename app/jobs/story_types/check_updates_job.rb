# frozen_string_literal: true

# Check if 'check_updates' method is developed?
module StoryTypes
  class CheckUpdatesJob < StoryTypesJob
    def perform(id = nil)
      story_types(id).each do |story_type|
        # sleep rand(5..10)
        code = story_type.code.try(:download)
        pp "> "*50, code&.include?('def check_updates')
        story_type.reminder.update(has_updates: nil) unless code || code&.include?('def check_updates')
      end
    end

    private

    def story_types(id)
      return StoryType.where(id: id) if id

      StoryType.ongoing.with_developer
    end
  end
end
