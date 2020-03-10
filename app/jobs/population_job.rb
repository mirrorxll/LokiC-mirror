# frozen_string_literal: true

class PopulationJob < ApplicationJob
  queue_as :population

  def perform(story_id)
    story = Story.find(story_id)
    story.staging_table.execute_code('populate', {})
  end
end
