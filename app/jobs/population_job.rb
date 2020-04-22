# frozen_string_literal: true

class PopulationJob < ApplicationJob
  queue_as :population

  def perform(story_type, options)
    MiniLokiC::Story::Code.run(
      story_type: story_type,
      method: 'population',
      options: options
    )
  end
end
