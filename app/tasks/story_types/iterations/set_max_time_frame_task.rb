# frozen_string_literal: true

module StoryTypes
  module Iterations
    class SetMaxTimeFrameTask < StoryTypesTask
      def perform(story_type_id)
        story_type    = StoryType.find(story_type_id)
        stories       = story_type.stories.exported
        time_frames   = stories.joins(:time_frame).pluck('time_frames.frame')
        sorted_frames = time_frames.sort_by { |frame| [frame.split(':')[-1].to_i, frame.split(':')[1].to_i] }

        story_type.update!(max_time_frame: sorted_frames.last)
      end
    end
  end
end
