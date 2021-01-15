# frozen_string_literal: true

class PurgeSamplesByLastIterationJob < ApplicationJob
  queue_as :creation

  def perform(story_type)
    ActiveRecord::Base.uncached do

      story_type.iteration.samples.destroy_all
      story_type.staging_table.samples_set_not_created
      story_type.iteration.update(story_samples: nil, creation: nil)

      status = true
      message = 'last iteration purged.'
    rescue StandardError => e
      status = nil
      message = e
    ensure
      story_type.iteration.update(population: status)
      send_to_action_cable(story_type, purge_last_creation_msg: message)
      send_to_slack(story_type, message)
    end
  end
end
