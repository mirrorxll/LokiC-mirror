class CreationJob < ApplicationJob
  queue_as :creation

  def perform(story_type_id)
    story_type = StoryType.find(story_type_id)
    story_type.staging_table.execute_code('create', {})
  end
end
