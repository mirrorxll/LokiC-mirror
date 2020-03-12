# frozen_string_literal: true

class PopulationWorker
  include Sidekiq::Worker

  def perform(story_type_id)
    story_type = StoryType.find(story_type_id)
    story_type.staging_table.execute_code('populate', {})
  end
end
