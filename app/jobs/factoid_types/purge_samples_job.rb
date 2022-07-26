# frozen_string_literal: true

module FactoidTypes
  class PurgeSamplesJob < FactoidTypesJob
    def perform(iteration_id, account_id)
      iteration = FactoidTypeIteration.find(iteration_id)
      account = Account.find(account_id)
      message = 'Success. samples have been removed'

      iteration.articles.where(sampled: true).destroy_all
    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      iteration.update!(purge_samples: nil, samples: nil, current_account: account)
      send_to_action_cable(iteration.factoid_type, :samples, message)
    end
  end
end
