class PurgeLastCreationJob < ApplicationJob
  queue_as :purge_last_creation

  def perform(story_id)
    story = Story.find(story_id)
    story.staging_table.purge_last_creation
  end
end
