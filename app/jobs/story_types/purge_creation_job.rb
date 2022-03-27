# frozen_string_literal: true

module StoryTypes
  class PurgeCreationJob < StoryTypesJob
    def perform(iteration, account)
      message = 'Success. All stories have been removed'

      loop do
        iteration.stories.limit(10_000).destroy_all

        break if iteration.stories.reload.blank?
      end

      iteration.update!(
        samples: nil, creation: nil,
        schedule: nil, schedule_args: nil,
        schedule_counts: nil, current_account: account
      )
    rescue StandardError, ScriptError => e
      message = e.message
    ensure
      iteration.update!(purge_creation: nil, current_account: account)
      send_to_action_cable(iteration.story_type, :samples, message)
      StoryTypes::SlackNotificationJob.perform_now(iteration, 'creation', message)
    end
  end
end
