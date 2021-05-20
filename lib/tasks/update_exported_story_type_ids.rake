# frozen_string_literal: true

namespace :exported_story_types do
  desc 'create a new user'
  task update_ids: :environment do
    ExportedStoryType.all.each { |est| est.update(story_type: est.iteration.story_type) }
  end
end
