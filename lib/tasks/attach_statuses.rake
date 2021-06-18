# frozen_string_literal: true

namespace :story_types do
  desc 'create a new user'
  task attach_statuses: :environment do
    Iteration.where(status: nil).each do |iter|
      iter.update(status: iter.statuses.first)
    end

    StoryType.where(status: nil).each do |stp|
      stp.update(status: stp.iteration.statuses.first)
    end
  end
end
