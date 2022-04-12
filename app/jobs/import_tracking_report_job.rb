# frozen_string_literal: true

class ImportTrackingReportJob < ApplicationJob
  sidekiq_options queue: :lokic

  def perform(url, worksheet, range, account_id, week)
    account = Account.find(account_id)
    row_reports = Reports::ImportTrackingHours.from_google_drive(url, worksheet, range, account, week)

    ActionCable.server.broadcast('ImportTrackingReportChannel', row_reports)
  end
end
