# frozen_string_literal: true

# Execute population method on sidekiq backend
module FactoidTypes
  class PopulationJob < FactoidTypesJob
    def perform(iteration_id, account_id, options)
      options.deep_symbolize_keys!

      iteration = FactoidTypeIteration.find(iteration_id)
      account = Account.find(account_id)
      status = true
      message = 'Success'
      factoid_type = iteration.factoid_type
      population_args = population_args_to_hash(options[:population_args])
      MiniLokiC::FactoidTypeCode[factoid_type].execute(:population, population_args)

      unless factoid_type.status.name.in?(['in progress', 'on cron'])
        factoid_type.update!(status: Status.find_by(name: 'in progress'), current_account: account)
      end

      true
    rescue StandardError, ScriptError => e
      status = nil
      message = e.message
    ensure
      iteration.update!(population: status, current_account: account)
      send_to_action_cable(factoid_type, :staging_table, message)
      SlackIterationNotificationJob.new.perform(iteration.id, 'population', message)
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
end
