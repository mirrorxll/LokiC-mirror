# frozen_string_literal: true

namespace :story_type do
  desc 'update story_type_id column'
  task update_column_in_iterations: :environment do
    StoryTypeIteration.all.each do |iter|
      Story.where(iteration: iter).update_all(story_type_id: iter.story_type.id)
    end

    puts
  end
end
