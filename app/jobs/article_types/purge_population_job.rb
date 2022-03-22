# frozen_string_literal: true

module ArticleTypes
  class PurgePopulationJob < ArticleTypesJob
    def perform(staging_table, iteration, account)
      message = 'Success. Staging Table Rows for current iteration purged'

      Process.wait(fork { staging_table.purge_current_iteration })
    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      iteration.update!(population: nil, purge_population: nil, current_account: account)
      send_to_action_cable(iteration.article_type, :staging_table, message)
      SlackNotificationJob.perform_now(iteration.article_type, iteration, 'population', message)
    end
  end
end
