# frozen_string_literal: true

class CreationJob < ApplicationJob
  queue_as :creation

  def perform(staging_table, params)
    MiniLokiC::Code.execute(staging_table.story_type, :creation)
    status = true
    message = 'all stories created.'
  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update_iteration(creation: status)
    send_status(story_type, message)
  end
end
