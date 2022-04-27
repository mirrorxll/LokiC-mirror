# frozen_string_literal: true

namespace :story_type do
  namespace :setup do
    desc 'Fill in max_time_frame for existing story_types'
    task fill_max_time_frames: :environment do
      StoryType.all.each { |story_type| StoryTypes::Iterations::SetMaxTimeFrameTask.new.perform(story_type.id) }
    end
  end
end
