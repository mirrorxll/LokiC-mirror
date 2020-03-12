# frozen_string_literal: true

class PurgeLastPopulationWorker
  include Sidekiq::Worker

  def perform(story_type_id)
    story_type = StoryType.find(story_type_id)
    story_type.staging_table.purge_last_population
  end
end
