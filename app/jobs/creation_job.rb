# frozen_string_literal: true

class CreationJob < ApplicationJob
  queue_as :creation

  def perform(story_type, options = {})
    MiniLokiC::Code.execute(story_type, :creation, options)
    status = true
    message = 'all samples created.'
  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update_iteration(creation: status)
    send_to_action_cable(story_type, creation_msg: status)
    send_to_slack(story_type, message)
  end
end
