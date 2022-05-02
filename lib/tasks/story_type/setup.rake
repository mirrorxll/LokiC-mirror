# frozen_string_literal: true

namespace :story_type do
  namespace :setup do
    desc 'Fill in max_time_frame for existing story_types'
    task time_frames_and_next_export: :environment do
      StoryType.all.each do |story_type|
        StoryTypes::Iterations::SetMaxTimeFrameTask.new.perform(story_type.id)
        StoryTypes::Iterations::SetNextExportDateTask.new.perform(story_type.id)
      end
    end
  end
end
