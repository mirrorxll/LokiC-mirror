# frozen_string_literal: true

class ExportJob < ApplicationJob
  queue_as :export

  def perform(story_type)
    Samples[:production].export!(story_type)
    status = true
    message = 'exported.'
  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update_iteration(export: status)
    ExportedStoryType.new(developer: story_type.developer,
                          iteration: story_type.iteration,
                          first_export: story_type.iterations.count > 1,
                          date_export: DateTime.now).save if status
    send_to_action_cable(story_type, export_msg: status)
    send_to_slack(story_type, message)
  end
end
