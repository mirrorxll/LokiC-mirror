# frozen_string_literal: true

class RemoveSamplesByIterationJob < ApplicationJob
  queue_as :story_type

  def perform(iteration, account)
    message = 'Success. All samples have been removed'

    loop do
      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close

          iteration.samples.limit(10_000).destroy_all
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

      break if iteration.samples.reload.blank?
    end

    iteration.update!(
      samples: nil, creation: nil,
      schedule: nil, schedule_args: nil,
      schedule_counts: nil, current_account: account
    )
  rescue StandardError => e
    message = e.message
  ensure
    iteration.update!(purge_all_samples: nil, current_account: account)
    send_to_action_cable(iteration, :samples, message)
    SlackStoryTypeNotificationJob.perform_now(iteration, 'creation', message)
  end
end
