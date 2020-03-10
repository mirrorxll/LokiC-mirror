class PurgeLastPopulationJob < ApplicationJob
  queue_as :purge_last_population

  def perform(story_id)
    story = Story.find(story_id)
    story.staging_table.purge_last_population
  end
end
