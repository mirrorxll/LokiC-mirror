# frozen_string_literal: true

module MiniLokiC
  module Population
    module SidekiqStop
      def self.[](story_type_class)
        # pp " *"*50, story_type_class
        story_type_id = story_type_class.split('S').last

        story_type = StoryType.find(story_type_id)
        # pp "> "*50, story_type
        # pp "> "*50, story_type.sidekiq_stop

        story_type.sidekiq_stop.cancel
      end
    end
  end
end
