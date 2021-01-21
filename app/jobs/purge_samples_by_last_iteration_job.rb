# frozen_string_literal: true

class PurgeSamplesByLastIterationJob < ApplicationJob
  queue_as :creation

  def perform(story_type)
    Process.wait(
      fork do
        status = true
        iteration = story_type.iteration

        iteration.samples.destroy_all
        story_type.staging_table.samples_set_not_created
        iteration.update(story_samples: nil, creation: nil)
      rescue StandardError => e
        status = nil
      ensure
        iteration.reload.update(population: status)
        send_to_action_cable(story_type, iteration, purge_last_creation_msg: status)
      end
    )
  end
end
