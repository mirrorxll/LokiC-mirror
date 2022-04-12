# frozen_string_literal: true

class AssembledsJob < ApplicationJob
  sidekiq_options queue: :lokic

  def perform(week, link)
    assembleds = Assembled.where(week: week)
    new_link = Reports::Assembled2020.to_google_drive(assembleds)
    status = true

  rescue StandardError, ScriptError
    status = nil
  ensure
    ActionCable.server.broadcast('AssembledsChannel', new_link)
    link.delete if status && link
  end
end
