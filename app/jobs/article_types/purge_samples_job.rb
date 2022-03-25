# frozen_string_literal: true

module ArticleTypes
  class PurgeSamplesJob < ArticleTypesJob
    def perform(iteration, account)
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
