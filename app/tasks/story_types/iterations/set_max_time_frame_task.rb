# frozen_string_literal: true

module StoryTypes
  module Iterations
    class SetMaxTimeFrameTask < StoryTypesTask
      def perform(story_type_id)
        story_type    = StoryType.find(story_type_id)
        sorted_frames = StoryType.select('time_frames.frame as frame')
                                 .joins(stories: :time_frame)
                                 .where(id: story_type_id)
                                 .where.not("stories.pl_#{PL_TARGET}_story_id" => nil)
                                 .distinct
                                 .map(&:frame)
                                 .sort_by { |frame| [frame.split(':')[-1].to_i, frame.split(':')[1].to_i] }

        story_type.update!(max_time_frame: sorted_frames.last)
      end
    end
  end
end
