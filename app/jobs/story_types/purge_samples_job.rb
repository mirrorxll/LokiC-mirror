# frozen_string_literal: true

module StoryTypes
  class PurgeSamplesJob < StoryTypesJob
    def perform(iteration, account)
      message = 'Success. samples have been removed'

      iteration.stories.where(sampled: true).destroy_all
      iteration.auto_feedback_confirmations.destroy_all
    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      iteration.update!(samples: nil, current_account: account)
      send_to_action_cable(iteration.story_type, :samples, message)
    end
  end
end
