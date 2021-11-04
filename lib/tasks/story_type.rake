# frozen_string_literal: true

namespace :story_type do
  desc 'update story_type_id column'
  task update_column_in_iterations: :environment do
    StoryTypeIteration.all.each do |iter|
      Story.where(iteration: iter).update_all(story_type_id: iter.story_type.id)
    end

    puts
  end

  desc 'update counts with additional options - key-value hashes'
  task add_to_schedule_counts_new_options: :environment do
    StoryTypeIteration.all.each do |iter|
      current_schedule_counts = iter.schedule_counts || {}
      counts = {}
      stories = iter.stories

      counts[:total] = current_schedule_counts.fetch(:total, stories.count)
      if counts[:total].zero?
        counts[:scheduled], counts[:backdated] = 0
      else
        published = stories.where.not(published_at: nil)
        counts[:scheduled] = published.where(backdated: 0).count
        counts[:backdated] = published.count - counts[:scheduled]
      end
      iter.update!(schedule_counts: current_schedule_counts.merge(counts))
      print '.'
    end

    puts 'All iterations\' "schedule count" fields had updated'
  end
end
