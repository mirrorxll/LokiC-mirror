# frozen_string_literal: true

namespace :story_type do
  namespace :setup do
    desc 'Find out max_time_frame'
    task set_max_time_frame: [:environment, :story_type_id] do |_, args|
      story_type    = StoryType.find(args[:story_type_id])
      stories       = story_type.stories.exported
      time_frames   = stories.joins(:time_frame).pluck('time_frames.frame')
      sorted_frames = time_frames.sort_by { |frame| [frame.split(':')[-1].to_i, frame.split(':')[1].to_i] }

      story_type.update!(max_time_frame: sorted_frames.last)
    end

    desc 'Fill in max_time_frame for existing story_types'
    task fill_max_time_frames: :environment do
      StoryType.all.each do |story_type|
        Rake::Task['story_type:setup:set_max_time_frame'].execute({ story_type_id: story_type.id })
      end
    end
  end
end
