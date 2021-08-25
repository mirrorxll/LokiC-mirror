# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  sidekiq_options retry: false

  private

  def generate_url(model)
    host = Rails.env.production? ? 'https://lokic.locallabs.com' : 'http://localhost:3000'
    "#{host}#{Rails.application.routes.url_helpers.send("#{model.class.to_s.underscore}_path", model)}"
  end

  def record_to_change_history(model, event, note, account)
    model.change_history.create!(event: event, note: note, account: account)
  end

  def record_to_alerts(model, subtype, message)
    model.alerts.create!(subtype: subtype, message: message)
  end
end
