# frozen_string_literal: true

# Execute population method on sidekiq backend
class PopulationJob < ApplicationJob
  queue_as :story_type

  def perform(iteration, account, options = {})
    Process.wait(
      fork do
        status = true
        message = 'Success'
        story_type = iteration.story_type
        population_args = population_args_to_hash(options[:population_args])

        MiniLokiC::Code[story_type].execute(:population, population_args)

        unless story_type.status.name.eql?('in progress')
          story_type.update!(status: Status.find_by(name: 'in progress'), current_account: account)
        end

        ExportConfigurationsJob.perform_now(story_type, account)
      rescue StandardError, ScriptError => e
        status = nil
        message = e.message
      ensure
        iteration.update!(population: status, current_account: account)
        send_to_action_cable(iteration, :staging_table, message)
        SlackStoryTypeNotificationJob.perform_now(iteration, 'population', message)
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
