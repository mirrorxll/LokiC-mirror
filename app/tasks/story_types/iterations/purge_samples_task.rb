# frozen_string_literal: true

module StoryTypes
  module Iterations
    class PurgeSamplesTask < StoryTypesTask
      def perform(iteration_id, account_id)
        iteration = StoryTypeIteration.find(iteration_id)
        account = Account.find(account_id)
        message = 'Success. samples have been removed'

        iteration.stories.where(sampled: true).destroy_all
        iteration.auto_feedback_confirmations.destroy_all
      rescue StandardError, ScriptError => e
        message = e.message
      ensure
        iteration.update!(purge_samples: nil, samples: nil, current_account: account)
        send_to_action_cable(iteration.story_type, :samples, message)
      end
    end
  end
end
