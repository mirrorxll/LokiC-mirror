# frozen_string_literal: true

# Execute population method on sidekiq backend
class PopulationJob < ApplicationJob
  queue_as :story_type

  def perform(iteration, options = {})
    Process.wait(
      fork do
        status = true
        message = 'Success'

        MiniLokiC::Code.execute(iteration, :population, options)
        ExportConfigurationsJob.perform_now(iteration.story_type)

      rescue StandardError, ScriptError => e
        status = nil
        message = e
      ensure
        iteration.update(population: status)
        send_to_action_cable(iteration, :staging_table, message)
        send_to_dev_slack(iteration, 'POPULATION', message)
      end
    )

    iteration.reload.population
  end
end
