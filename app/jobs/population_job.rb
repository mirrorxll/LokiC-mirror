# frozen_string_literal: true

# Execute population method on sidekiq backend
class PopulationJob < ApplicationJob
  queue_as :story_type

  def perform(iteration, options = {})
    Process.wait(
      fork do
        status = true
        message = 'Success'
        story_type = iteration.story_type
        population_args = population_args_to_hash(options[:population_args])

        MiniLokiC::Code[story_type].execute(:population, population_args)

        note = "progress status changed to 'in progress'"
        record_to_change_history(story_type, 'progress status changed', note)

        ExportConfigurationsJob.perform_now(story_type)
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

  private

  def population_args_to_hash(args)
    args.split(' :: ').each_with_object({}) do |option, hash|
      next unless option.match?(/=>/)

      key, value = option.split('=>')
      hash[key] = value
    end
  end
end
