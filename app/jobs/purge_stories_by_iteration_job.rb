# frozen_string_literal: true

class PurgeStoriesByIterationJob < ApplicationJob
  queue_as :story_type

  def perform(iteration, account)
    message = 'Success. All stories have been removed'

    loop do
      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close

          iteration.stories.limit(10_000).destroy_all
        rescue StandardError => e
          wr.write({ e.class.to_s => e.message }.to_json)
        ensure
          wr.close
        end
      )

      wr.close
      exception = rd.read
      rd.close

      if exception.present?
        klass, message = JSON.parse(exception).to_a.first
        raise Object.const_get(klass), message
      end

      break if iteration.stories.reload.blank?
    end

    iteration.update!(
      samples_creation: nil, creation: nil,
      schedule: nil, schedule_args: nil,
      schedule_counts: nil, current_account: account
    )
  rescue StandardError => e
    message = e.message
  ensure
    iteration.update!(purge_stories: nil, current_account: account)
    send_to_action_cable(iteration.story_type, :samples, message)
    SlackStoryTypeNotificationJob.perform_now(iteration, 'creation', message)
  end
end
