# frozen_string_literal: true

class AssembledJob < ApplicationJob
  queue_as :export

  def perform(assembleds)
    @link = Reports::Assembled2020.to_google_drive(assembleds)
    status = true
    message = 'exported.'
  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update_iteration(export: status)

    send_to_action_cable(story_type, export_msg: status)
    send_to_slack(story_type, message)
  end
end
