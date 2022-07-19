# frozen_string_literal: true

module FactoidTypes
  class PurgeCreationJob < FactoidTypesJob
    def perform(iteration_id, account_id)
      iteration = FactoidTypeIteration.find(iteration_id)
      account = Account.find(account_id)
      message = 'Success. All articles have been removed'

      loop do
        iteration.articles.limit(10_000).destroy_all

        break if iteration.articles.reload.blank?
      end

      iteration.update!(samples: nil, creation: nil, current_account: account)
    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      iteration.update!(purge_creation: nil, current_account: account)
      send_to_action_cable(iteration.article_type, :samples, message)
      SlackIterationNotificationJob.new.perform(iteration.id, 'creation', message)
    end
  end
end
