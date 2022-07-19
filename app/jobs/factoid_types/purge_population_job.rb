# frozen_string_literal: true

module FactoidTypes
  class PurgePopulationJob < FactoidTypesJob
    def perform(staging_table_id, iteration_id, account_id)
      staging_table = StagingTable.find(staging_table_id)
      iteration = FactoidTypeIteration.find(iteration_id)
      account = Account.find(account_id)
      message = 'Success. Staging Table Rows for current iteration purged'

      staging_table.purge_current_iteration
    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      iteration.update!(population: nil, purge_population: nil, current_account: account)
      send_to_action_cable(iteration.article_type, :staging_table, message)
      SlackIterationNotificationJob.new.perform(iteration.id, 'population', message)
    end
  end
end
