# frozen_string_literal: true

module FactoidTypes
  class PurgeSamplesJob < ArticleTypesJob
    def perform(iteration_id, account_id)
      iteration = ArticleTypeIteration.find(iteration_id)
      account = Account.find(account_id)
      message = 'Success. samples have been removed'

      iteration.articles.where(sampled: true).destroy_all
    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      iteration.update!(samples: nil, current_account: account)
      send_to_action_cable(iteration.article_type, :samples, message)
    end
  end
end
