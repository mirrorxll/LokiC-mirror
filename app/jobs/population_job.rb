# frozen_string_literal: true

# Execute population method on sidekiq backend
class PopulationJob < ApplicationJob
  queue_as :population

  def perform(iteration, options = {})
    Process.wait(
      fork do
        status = true
        message = 'Success'

        MiniLokiC::Code.execute(iteration.story_type, :population, options)

        iteration.update(population: true)
      rescue StandardError => e
        status = nil
        message = e
      ensure
        iteration.update(population: status)
        send_to_action_cable(iteration, population_msg: message)
        send_to_slack(iteration, 'POPULATION', message)
      end
    )

    iteration.reload.population
  end
end
