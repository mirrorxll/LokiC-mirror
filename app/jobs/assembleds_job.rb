# frozen_string_literal: true

class AssembledsJob < ApplicationJob
  queue_as :assembleds

  def perform(week)
    assembleds = Assembled.where(week: week)
    link = LinkAssembled.find_by(week: week)
    Reports::Assembled2020.to_google_drive(assembleds)
    status = true
  rescue StandardError => e
    status = nil
  ensure
    link.delete if status
  end
end
