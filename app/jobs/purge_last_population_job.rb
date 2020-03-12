class PurgeLastPopulationJob < ApplicationJob
  queue_as :purge_last_population

  def perform(story_type_id)
    story_type = StoryType.find(story_type_id)
    story_type.staging_table.purge_last_population
  end
end
