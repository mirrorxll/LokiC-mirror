# frozen_string_literal: true

class ExportJob < ApplicationJob
  queue_as :export

  def perform(environment, story_type, options)
    Stories[environment].export(story_type, options)

    status = true
    message = 'exported.'
  rescue StandardError => e
    status = nil
    message = e
  ensure
    story_type.update_iteration(export: status)
    send_status(story_type, export: message)
  end
end
