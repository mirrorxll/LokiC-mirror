class CreationJob < ApplicationJob
  queue_as :creation

  def perform(story_id)
    story = Story.find(story_id)
    story.staging_table.execute_code('create', {})
  end
end
