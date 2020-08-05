# frozen_string_literal: true

# Execute population method on sidekiq backend
class PopulationJob < ApplicationJob
  queue_as :population

  def perform(story_type, options = {})
    MiniLokiC::Code.execute(story_type, :population, options)
    story_type.update_iteration(population: true)
    status = true
    message = 'population success'

  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update_iteration(population: status)
    send_to_action_cable(story_type, population_msg: message)
    send_to_slack(story_type, message)
  end
end
