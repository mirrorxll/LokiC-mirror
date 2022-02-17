# frozen_string_literal: true

module MiniLokiC
  module Population
    module SidekiqBreak
      def self.[](story_type_class)
        story_type_id = story_type_class.split('S').last
        story_type = StoryType.find(story_type_id)
        story_type.sidekiq_break.cancel
      end
    end
  end
end
