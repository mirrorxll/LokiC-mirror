# frozen_string_literal: true

class PopulationJob < ApplicationJob
  queue_as :population

  def perform(story_type_id)
    story_type = StoryType.find(story_type_id)
    story_type.staging_table.execute_code('populate', {})
  end
end
