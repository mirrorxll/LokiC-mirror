# frozen_string_literal: true

class PopulationJob < ApplicationJob
  queue_as :population

  def perform(story_type, options)
    MiniLokiC::Code.execute(story_type, :population, options)
  end
end
