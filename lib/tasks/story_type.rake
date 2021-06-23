# frozen_string_literal: true

namespace :story_type do
  desc 'filling in empty distributed_at TS for story types'
  task init_distributed_at: :environment do
    StoryType.where.not(developer: nil).each do |st_type|
      st_type.update(distributed_at: DateTime.now)
    end
  end

  desc 'filling in empty last_status_changed_at TS for story types'
  task init_last_status_changed_at: :environment do
    StoryType.all.each do |st_type|
      st_type.update(distributed_at: DateTime.now)
    end
  end
end
