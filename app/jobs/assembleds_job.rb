# frozen_string_literal: true

class AssembledsJob < ApplicationJob
  queue_as :assembleds

  def perform(week, link)
    assembleds = Assembled.where(week: week)
    new_link = Reports::Assembled2020.to_google_drive(assembleds)
    status = true

  rescue StandardError => e
    status = nil
  ensure
    ActionCable.server.broadcast('AssembledsChannel', new_link)
    link.update_attribute(:in_process, false)
    link.delete if status && link
  end
end
