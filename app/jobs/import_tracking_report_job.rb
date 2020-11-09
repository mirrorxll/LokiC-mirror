# frozen_string_literal: true

class ImportTrackingReportJob < ApplicationJob
  queue_as :import

  def perform(url, worksheet, range, account, week)
    row_reports = Reports::ImportTrackingHours.from_google_drive(url, worksheet, range, account, week)

    ActionCable.server.broadcast('ImportTrackingReportChannel', row_reports)
  end
end
