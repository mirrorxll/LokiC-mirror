# frozen_string_literal: true

module ArticleTypes
  class PurgeCreationJob < ArticleTypesJob
    def perform(iteration, account)
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
      SlackNotificationJob.perform_now(iteration.article_type, iteration, 'creation', message)
    end
  end
end
