# frozen_string_literal: true

class RemoveSamplesByLastIterationJob < ApplicationJob
  queue_as :story_type

  def perform(iteration)
    Process.wait(
      fork do
        message = 'Success. All samples have been removed'

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
        send_to_action_cable(iteration, :purge_last_creation, message)
      end
    )
  end
end
