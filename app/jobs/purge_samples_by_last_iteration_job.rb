# frozen_string_literal: true

class PurgeSamplesByLastIterationJob < ApplicationJob
  queue_as :creation

  def perform(story_type)
    story_type.iteration.samples.destroy_all
    story_type.staging_table.samples_set_not_created
    story_type.update_iteration(story_samples: nil, story_sample_ids: nil, creation: nil)

    status = true
    message = 'last iteration purged.'
  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update_iteration(population: status)
    send_to_action_cable(story_type, purge_last_creation_msg: status)
    send_to_slack(story_type, message)
  end
end
