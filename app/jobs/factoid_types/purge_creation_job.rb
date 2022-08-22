# frozen_string_literal: true

module FactoidTypes
  class PurgeCreationJob < FactoidTypesJob
    def perform(iteration_id, account_id)
      iteration = FactoidTypeIteration.find(iteration_id)
      account   = Account.find(account_id)
      message   = 'Success. All factoids have been removed'

      loop do
        iteration.factoids.limit(10_000).destroy_all

        break if iteration.factoids.reload.blank?
      end

      iteration.update!(samples: nil, creation: nil, current_account: account)
    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      iteration.update!(purge_creation: nil, current_account: account)
      send_to_action_cable(iteration.factoid_type, :samples, message)
      SlackIterationNotificationJob.new.perform(iteration.id, 'creation', message)
    end
  end
end
