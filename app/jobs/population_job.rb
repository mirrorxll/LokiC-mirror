# frozen_string_literal: true

# Execute population method on sidekiq backend
class PopulationJob < ApplicationJob
  queue_as :population

  def perform(story_type, options = {})
    Process.wait(
      fork do
        status = true
        message = 'SUCCESS'
        iteration = story_type.iteration

        MiniLokiC::Code.execute(story_type, :population, options)

        iteration.reload.update(population: true)
      rescue StandardError => e
        status = nil
        message = e
      ensure
        story_type.iteration.update(population: status)
        send_to_action_cable(story_type, iteration, population_msg: message)
        send_to_slack(story_type, 'population', message)
      end
    )
  end
end
