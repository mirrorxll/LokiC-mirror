# frozen_string_literal: true

# Execute population method on sidekiq backend
class PopulationJob < ApplicationJob
  queue_as :story_type

  def perform(iteration, options = {})
    status = true
    message = 'Success'
    story_type = iteration.story_type
    old_status = story_type.status.name
    population_args = population_args_to_hash(options[:population_args])

    Process.wait(
      fork do
        MiniLokiC::Code[story_type].execute(:population, population_args)

        unless old_status.name.eql?('in progress')
          story_type.update(status: Status.find_by(name: 'in progress'))
          body = "#{old_status} -> in progress"
          record_to_change_history(story_type, 'progress status changed', body, options[:account])
        end

        ExportConfigurationsJob.perform_now(story_type)
      rescue StandardError, ScriptError => e
        status = nil
        message = e.message
      ensure
        iteration.update!(population: status)
        send_to_action_cable(iteration, :staging_table, message)
        send_to_dev_slack(iteration, 'POPULATION', message)
      end
    )

    true
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
