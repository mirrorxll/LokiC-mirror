# frozen_string_literal: true

class ExportJob < ApplicationJob
  queue_as :export

  def perform(story_type)
    status = true
    message = Samples[PL_TARGET].export!(story_type)
  rescue StandardError => e
    status = nil
    message = e.full_message
  ensure
    story_type.update_iteration(export: status)
    send_to_action_cable(story_type, export_msg: status)
    send_to_slack(story_type, "export\n#{message}")
  end
end
