# frozen_string_literal: true

class PurgeSamplesByLastIterationJob < ApplicationJob
  queue_as :creation

  def perform(iteration)
    Process.wait(
      fork do
        message = 'PURGED'

        iteration.samples.destroy_all
        iteration.story_type.staging_table.samples_set_not_created
        iteration.update(story_samples: nil, creation: nil)

        iteration.update(
          creation: nil, schedule: nil,
          schedule_args: nil, schedule_counts: nil
        )
      rescue StandardError => e
        message = e.message
      ensure
        iteration.update(purge_all_samples: nil)
        send_to_action_cable(iteration, purge_last_creation_msg: message)
      end
    )
  end
end
